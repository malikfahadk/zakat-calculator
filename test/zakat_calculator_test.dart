import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_calculator/zakat_calculator.dart';

void main() {
  test('calculates zakat when amount is above nisab', () {
    final result = ZakatCalculator.calculate(
      const ZakatCalculationInput(
        cash: 2000,
        savings: 3000,
        investments: 1000,
        goldGrams: 10,
        goldPricePerGram: 100,
        silverGrams: 0,
        silverPricePerGram: 1,
        liabilities: 500,
        zakatRate: 0.025,
      ),
    );

    expect(result.isEligible, isTrue);
    expect(result.totalAssets, closeTo(7000, 0.001));
    expect(result.netZakatableAmount, closeTo(6500, 0.001));
    expect(result.zakatDue, closeTo(162.5, 0.001));
  });

  test('returns zero zakat when below nisab', () {
    final result = ZakatCalculator.calculate(
      const ZakatCalculationInput(
        cash: 100,
        savings: 50,
        investments: 0,
        goldGrams: 0,
        goldPricePerGram: 100,
        silverGrams: 0,
        silverPricePerGram: 1,
        liabilities: 0,
        zakatRate: 0.025,
      ),
    );

    expect(result.isEligible, isFalse);
    expect(result.zakatDue, 0);
  });
}
