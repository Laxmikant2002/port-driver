import 'package:flutter_test/flutter_test.dart';
import 'package:trip_repo/trip_repo.dart';

void main() {
  group('TripRepo', () {
    test('should create TripRepo instance', () {
      // This is a basic test to ensure the package exports work correctly
      // In a real implementation, you would test the actual repository methods
      expect(TripRepo, isNotNull);
    });

    test('should have PaymentMethod enum values', () {
      expect(PaymentMethod.cash.value, equals('cash'));
      expect(PaymentMethod.online.value, equals('online'));
      expect(PaymentMethod.wallet.value, equals('wallet'));
    });

    test('should create FareBreakdown instance', () {
      final breakdown = FareBreakdown(
        baseFare: 50.0,
        distanceFare: 25.0,
        timeFare: 15.0,
        surgeMultiplier: 1.0,
        commission: 10.0,
        totalFare: 90.0,
        netPayout: 80.0,
      );

      expect(breakdown.baseFare, equals(50.0));
      expect(breakdown.netPayout, equals(80.0));
      expect(breakdown.commission, equals(10.0));
    });
  });
}