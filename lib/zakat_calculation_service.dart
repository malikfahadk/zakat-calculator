import 'zakat_calculator.dart';

class ZakatCalculationService {
  const ZakatCalculationService();

  ZakatCalculationResult calculatePkr({
    required double nisabAmount,
    required double cash,
    required double bankBalance,
    required double otherAssets,
    required double liabilities,
    required double zakatRate,
  }) {
    return ZakatCalculator.calculate(
      ZakatCalculationInput(
        cash: cash,
        savings: bankBalance,
        investments: otherAssets,
        goldGrams: 0,
        goldPricePerGram: 0,
        silverGrams: 0,
        silverPricePerGram: 0,
        liabilities: liabilities,
        zakatRate: zakatRate,
        nisabAmount: nisabAmount,
      ),
    );
  }
}
