class ZakatInput {
  const ZakatInput({
    required this.nisabAmount,
    required this.cash,
    required this.bankBalance,
    required this.otherAssets,
    required this.liabilities,
    required this.zakatRate,
    required this.standard,
    required this.valuationDate,
    required this.oneHijriYear,
    this.source,
  });

  factory ZakatInput.fromJson(Map<String, dynamic> json) {
    double amount(String key) {
      final value = json[key];
      if (value is! num || value < 0 || !value.isFinite) {
        throw FormatException('$key must be a non-negative number');
      }
      return value.toDouble();
    }

    final nisab = amount('nisabAmount');
    if (nisab <= 0) throw const FormatException('nisabAmount must be greater than zero');
    final zakatRate = amount('zakatRate');
    if (zakatRate <= 0 || zakatRate > 100) {
      throw const FormatException('zakatRate must be between 0 and 100 percent');
    }
    final date = DateTime.tryParse(json['valuationDate']?.toString() ?? '');
    if (date == null) throw const FormatException('valuationDate must be YYYY-MM-DD');
    final standard = json['standard']?.toString();
    if (standard != 'silver' && standard != 'gold') {
      throw const FormatException('standard must be silver or gold');
    }
    return ZakatInput(
      nisabAmount: nisab,
      cash: amount('cash'),
      bankBalance: amount('bankBalance'),
      otherAssets: amount('otherAssets'),
      liabilities: amount('liabilities'),
      zakatRate: zakatRate / 100,
      standard: standard!,
      valuationDate: date,
      oneHijriYear: json['oneHijriYear'] == true,
      source: json['source']?.toString(),
    );
  }

  final double nisabAmount;
  final double cash;
  final double bankBalance;
  final double otherAssets;
  final double liabilities;
  final double zakatRate;
  final String standard;
  final DateTime valuationDate;
  final bool oneHijriYear;
  final String? source;

  Map<String, dynamic> toJson() {
    final totalAssets = cash + bankBalance + otherAssets;
    final net = (totalAssets - liabilities).clamp(0, double.infinity).toDouble();
    final eligible = net >= nisabAmount;
    return {
      'standard': standard,
      'nisabAmount': nisabAmount,
      'totalAssets': totalAssets,
      'cash': cash,
      'bankBalance': bankBalance,
      'otherAssets': otherAssets,
      'liabilities': liabilities,
      'netZakatableAmount': net,
      'isEligible': eligible,
      'zakatRate': zakatRate * 100,
      'zakatDue': eligible ? net * zakatRate : 0,
      'valuationDate': valuationDate.toIso8601String().split('T').first,
      'oneHijriYear': oneHijriYear,
      if (source != null && source!.isNotEmpty) 'source': source,
    };
  }
}
