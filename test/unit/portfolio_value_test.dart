// Unit tests for the depreciation / current-value logic in PortfolioService.
//
// The exact formula from portfolio_service.dart:
//   double _depreciationRate(String sport) {
//     if sport contains 'paraglid' | 'kříd' | 'wing' → 0.15
//     if sport contains 'kol' | 'bike' | 'cykl'      → 0.10
//     if sport contains 'lan' | 'rope' | 'horolezec' → 0.20
//     default                                         → 0.10
//   }
//
//   double _currentValue(double price, DateTime? purchaseDate, String sport) {
//     if purchaseDate == null → return price
//     years = now.difference(purchaseDate).inDays / 365.0
//     factor = (1.0 - rate * years).clamp(0.1, 1.0)
//     return price * factor
//   }
//
// We replicate this formula here and test edge-cases against expected values.

import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Inline replica of the private PortfolioService methods (no DB calls needed).
// ---------------------------------------------------------------------------

double depreciationRate(String sport) {
  final lower = sport.toLowerCase();
  if (lower.contains('paraglid') ||
      lower.contains('kříd') ||
      lower.contains('wing')) return 0.15;
  if (lower.contains('kol') ||
      lower.contains('bike') ||
      lower.contains('cykl')) return 0.10;
  if (lower.contains('lan') ||
      lower.contains('rope') ||
      lower.contains('horolezec')) return 0.20;
  return 0.10;
}

double currentValue(
  double purchasePrice,
  DateTime? purchaseDate,
  String sport, {
  DateTime? now,
}) {
  if (purchaseDate == null) return purchasePrice;
  final effectiveNow = now ?? DateTime.now();
  final years = effectiveNow.difference(purchaseDate).inDays / 365.0;
  final rate = depreciationRate(sport);
  final factor = (1.0 - rate * years).clamp(0.1, 1.0);
  return purchasePrice * factor;
}

// ---------------------------------------------------------------------------

void main() {
  group('depreciationRate', () {
    test('paragliding gear → 15% per year', () {
      expect(depreciationRate('paragliding'), closeTo(0.15, 0.0001));
      expect(depreciationRate('Paraglider wing'), closeTo(0.15, 0.0001));
      expect(depreciationRate('křídlo'), closeTo(0.15, 0.0001));
    });

    test('bike/cycling gear → 10% per year', () {
      expect(depreciationRate('kolo'), closeTo(0.10, 0.0001));
      expect(depreciationRate('bike'), closeTo(0.10, 0.0001));
      expect(depreciationRate('cyklistika'), closeTo(0.10, 0.0001));
    });

    test('rope/climbing gear → 20% per year', () {
      expect(depreciationRate('lano'), closeTo(0.20, 0.0001));
      expect(depreciationRate('rope'), closeTo(0.20, 0.0001));
      expect(depreciationRate('horolezectví'), closeTo(0.20, 0.0001));
    });

    test('other/unknown sport → default 10% per year', () {
      expect(depreciationRate('lezení'), closeTo(0.10, 0.0001));
      expect(depreciationRate('Ostatní'), closeTo(0.10, 0.0001));
      expect(depreciationRate('skiing'), closeTo(0.10, 0.0001));
    });
  });

  group('currentValue – depreciation calculation', () {
    test('paragliding gear bought exactly 1 year ago → 85% of purchase price', () {
      final now = DateTime(2025, 6, 15);
      final purchaseDate = DateTime(2024, 6, 15); // exactly 365 days ago

      final result = currentValue(10000, purchaseDate, 'paragliding', now: now);

      // factor = (1 - 0.15 * 1.0).clamp(0.1, 1.0) = 0.85
      expect(result, closeTo(8500, 1.0));
    });

    test('bike bought 2 years ago → 80% of purchase price', () {
      final now = DateTime(2026, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1); // 2 years ago

      final result = currentValue(5000, purchaseDate, 'bike', now: now);

      // factor = (1 - 0.10 * 2.0).clamp(0.1, 1.0) = 0.80
      expect(result, closeTo(4000, 5.0));
    });

    test('rope bought 5 years ago → floor at 10% of purchase price', () {
      final now = DateTime(2029, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1); // 5 years ago

      final result = currentValue(1000, purchaseDate, 'lano', now: now);

      // factor = (1 - 0.20 * 5.0).clamp(0.1, 1.0) = (0.0).clamp(0.1,1.0) = 0.1
      // result = 1000 * 0.1 = 100
      expect(result, closeTo(100, 1.0));
    });

    test('gear with no purchase date → returns full purchase price unchanged', () {
      final result = currentValue(3000, null, 'paragliding');
      expect(result, closeTo(3000, 0.001));
    });

    test('brand new gear (purchased today) → returns full purchase price', () {
      final now = DateTime(2025, 6, 15);
      // 0 days → years ≈ 0 → factor = (1 - 0) = 1.0
      final result = currentValue(2000, now, 'bike', now: now);
      expect(result, closeTo(2000, 1.0));
    });

    test('value never falls below 10% of purchase price (floor)', () {
      final now = DateTime(2040, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1); // 16 years ago

      final result = currentValue(5000, purchaseDate, 'lano', now: now);

      // Without clamp: 1 - 0.20*16 = -2.2 → clamped to 0.1
      // result = 5000 * 0.1 = 500
      expect(result, closeTo(500, 1.0));
      // Must be at least 10% of purchase price
      expect(result, greaterThanOrEqualTo(5000 * 0.1));
    });

    test('value never exceeds purchase price', () {
      final now = DateTime(2025, 1, 1);
      final purchaseDate = DateTime(2024, 12, 31); // 1 day ago
      final result = currentValue(8000, purchaseDate, 'bike', now: now);
      expect(result, lessThanOrEqualTo(8000));
    });
  });

  group('currentValue – depreciation rates by sport keyword', () {
    test('15% rate: value after 1 year paragliding = 85% of original', () {
      final now = DateTime(2025, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1);
      final result = currentValue(1000, purchaseDate, 'paraglider křídlo', now: now);
      expect(result, closeTo(850, 2.0));
    });

    test('10% default rate: value after 3 years = 70%', () {
      final now = DateTime(2027, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1);
      final result = currentValue(1000, purchaseDate, 'stan', now: now);
      // factor = (1 - 0.10 * 3).clamp(0.1,1.0) = 0.70
      expect(result, closeTo(700, 5.0));
    });

    test('20% rope rate: value after 3 years = 40%', () {
      final now = DateTime(2027, 1, 1);
      final purchaseDate = DateTime(2024, 1, 1);
      final result = currentValue(1000, purchaseDate, 'lano', now: now);
      // factor = (1 - 0.20 * 3).clamp(0.1,1.0) = 0.40
      expect(result, closeTo(400, 5.0));
    });
  });
}
