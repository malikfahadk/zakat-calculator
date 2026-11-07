class ZakatCalculationInput {
  const ZakatCalculationInput({
    required this.cash,
    required this.savings,
    required this.investments,
    required this.goldGrams,
    required this.goldPricePerGram,
    required this.silverGrams,
    required this.silverPricePerGram,
    required this.liabilities,
    required this.zakatRate,
    this.nisabAmount,
    this.nisabGramsSilver = 612.36,
  });

  final double cash;
  final double savings;
  final double investments;
  final double goldGrams;
  final double goldPricePerGram;
  final double silverGrams;
  final double silverPricePerGram;
  final double liabilities;
  final double zakatRate;
  final double? nisabAmount;
  final double nisabGramsSilver;
}

class ZakatCalculationResult {
  const ZakatCalculationResult({
    required this.totalAssets,
    required this.nisabAmount,
    required this.netZakatableAmount,
    required this.isEligible,
    required this.zakatDue,
  });

  final double totalAssets;
  final double nisabAmount;
  final double netZakatableAmount;
  final bool isEligible;
  final double zakatDue;
}

class ZakatCalculator {
  static ZakatCalculationResult calculate(ZakatCalculationInput input) {
    final totalAssets =
        input.cash +
        input.savings +
        input.investments +
        (input.goldGrams * input.goldPricePerGram) +
        (input.silverGrams * input.silverPricePerGram);
    final netZakatableAmount = (totalAssets - input.liabilities)
        .clamp(0, double.infinity)
        .toDouble();
    final nisabAmount =
        input.nisabAmount ??
        input.nisabGramsSilver * input.silverPricePerGram;
    final isEligible = netZakatableAmount >= nisabAmount;
    final zakatDue = isEligible ? netZakatableAmount * input.zakatRate : 0.0;

    return ZakatCalculationResult(
      totalAssets: totalAssets,
      nisabAmount: nisabAmount,
      netZakatableAmount: netZakatableAmount,
      isEligible: isEligible,
      zakatDue: zakatDue,
    );
  }
}
