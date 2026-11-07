import 'package:flutter_test/flutter_test.dart';
import 'package:zakat_calculator/zakat_calculation_service.dart';

void main() {
  test('calculates PKR Zakat from form values', () {
    const service = ZakatCalculationService();

    final result = service.calculatePkr(
      nisabAmount: 5000,
      cash: 2000,
      bankBalance: 3000,
      otherAssets: 1000,
      liabilities: 500,
      zakatRate: 0.025,
    );

    expect(result.totalAssets, 6000);
    expect(result.netZakatableAmount, 5500);
    expect(result.nisabAmount, 5000);
    expect(result.isEligible, isTrue);
    expect(result.zakatDue, 137.5);
  });

  test('does not charge Zakat below the configured nisab', () {
    const service = ZakatCalculationService();

    final result = service.calculatePkr(
      nisabAmount: 5000,
      cash: 1000,
      bankBalance: 1000,
      otherAssets: 0,
      liabilities: 0,
      zakatRate: 0.025,
    );

    expect(result.isEligible, isFalse);
    expect(result.zakatDue, 0);
  });
}
