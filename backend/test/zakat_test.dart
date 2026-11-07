import 'package:test/test.dart';
import 'package:zakat_calculator_backend/src/zakat.dart';

void main() {
  test('calculates eligible PKR Zakat at 2.5 percent', () {
    final input = ZakatInput.fromJson({
      'nisabAmount': 5000,
      'zakatRate': 2.5,
      'standard': 'silver',
      'valuationDate': '2026-10-31',
      'cash': 2000,
      'bankBalance': 3000,
      'otherAssets': 1000,
      'liabilities': 500,
      'oneHijriYear': true,
    });

    final result = input.toJson();
    expect(result['netZakatableAmount'], 5500);
    expect(result['isEligible'], isTrue);
    expect(result['zakatDue'], 137.5);
  });

  test('rejects invalid money values', () {
    expect(
      () => ZakatInput.fromJson({
        'nisabAmount': 5000,
        'zakatRate': 2.5,
        'standard': 'silver',
        'valuationDate': '2026-10-31',
        'cash': -1,
        'bankBalance': 0,
        'otherAssets': 0,
        'liabilities': 0,
      }),
      throwsFormatException,
    );
  });
}
