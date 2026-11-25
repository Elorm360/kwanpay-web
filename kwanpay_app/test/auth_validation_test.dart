import 'package:flutter_test/flutter_test.dart';
import 'package:kwanpay_app/core/services/auth_service.dart';

void main() {
  group('passwordProblem', () {
    test('rejects short passwords', () {
      expect(AuthService.passwordProblem('abc123'), isNotNull);
    });

    test('requires a letter and a number', () {
      expect(AuthService.passwordProblem('abcdefgh'), isNotNull);
      expect(AuthService.passwordProblem('12345678'), isNotNull);
    });

    test('accepts a sound password', () {
      expect(AuthService.passwordProblem('travel2026'), isNull);
    });
  });

  group('looksLikeEmail', () {
    test('accepts normal addresses', () {
      expect(AuthService.looksLikeEmail('ama@example.com'), isTrue);
    });

    test('rejects malformed addresses', () {
      expect(AuthService.looksLikeEmail('ama@example'), isFalse);
      expect(AuthService.looksLikeEmail('ama example.com'), isFalse);
    });
  });

  group('suggestEmailFix', () {
    test('catches common domain typos', () {
      expect(AuthService.suggestEmailFix('ama@gmaol.com'), 'ama@gmail.com');
      expect(AuthService.suggestEmailFix('ama@Yaho.com'), 'ama@yahoo.com');
    });

    test('leaves correct domains alone', () {
      expect(AuthService.suggestEmailFix('ama@gmail.com'), isNull);
      expect(AuthService.suggestEmailFix('ama@kwanpay.app'), isNull);
    });
  });
}
