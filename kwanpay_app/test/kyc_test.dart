import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/services/kyc_service.dart';
import 'package:kwanpay_app/core/utils/money_error.dart';
import 'package:kwanpay_app/features/kyc/presentation/limits_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('KycStatus.fromJson', () {
    test('reads the shape get_my_kyc_status returns', () {
      final s = KycStatus.fromJson({
        'tier': 0,
        'tier_name': 'Basic',
        'currency': 'GHS',
        'per_transaction_limit': 500.00,
        'daily_limit': '1000.00',
        'monthly_limit': 3000,
        'used_today': 0,
        'used_this_month': 450.5,
        'submission_status': null,
        'rejection_reason': null,
      });
      expect(s.tier, 0);
      expect(s.dailyLimit, 1000);
      expect(s.usedThisMonth, 450.5);
      expect(s.idVerified, isFalse);
      expect(s.underReview, isFalse);
      expect(s.rejected, isFalse);
    });

    test('a rejection after approval is not shown as rejected', () {
      final s = KycStatus.fromJson({
        'tier': 2,
        'tier_name': 'ID verified',
        'submission_status': 'rejected',
      });
      expect(s.idVerified, isTrue);
      expect(s.rejected, isFalse);
    });
  });

  group('ghs', () {
    test('groups thousands and drops empty pesewas', () {
      expect(ghs(0), 'GHS 0');
      expect(ghs(1000), 'GHS 1,000');
      expect(ghs(100000), 'GHS 100,000');
      expect(ghs(1234.5), 'GHS 1,234.50');
      expect(ghs(0.05), 'GHS 0.05');
    });
  });

  group('moneyErrorMessage', () {
    test('shows the database message for wallet refusals', () {
      const error = PostgrestException(
        message: 'This would take you over your daily limit of GHS 1,000.00.',
        code: 'P0001',
        hint: 'kyc_limit_daily',
      );
      expect(moneyErrorMessage(error), startsWith('This would take you over'));
      expect(isLimitError(error), isTrue);
    });

    test('hides technical errors', () {
      const error = PostgrestException(
        message: 'permission denied for table transactions',
        code: '42501',
      );
      expect(moneyErrorMessage(error), contains("couldn't complete"));
      expect(isLimitError(error), isFalse);
    });

    test('strips the Exception prefix', () {
      expect(moneyErrorMessage(Exception('Enter a valid amount.')),
          'Enter a valid amount.');
    });
  });
}
