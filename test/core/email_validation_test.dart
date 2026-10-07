import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/email_validation.dart';

void main() {
  group('EmailAddress.isValid', () {
    test('TC_C_EMAIL_001 — real addresses pass', () {
      for (final email in [
        'parent@example.com',
        'first.last@school.co.in',
        'name+tlb@gmail.com',
        'a_b-c@sub.domain.org',
        '  padded@example.com  ', // the field's value is trimmed
        'UPPER@EXAMPLE.COM',
      ]) {
        expect(EmailAddress.isValid(email), isTrue, reason: email);
      }
    });

    test('TC_C_EMAIL_002 — malformed addresses fail (bug_login_001: abc123)',
        () {
      for (final email in [
        'abc123',
        'abc@',
        '@example.com',
        'abc@example',
        'abc@example.c',
        'a b@example.com',
        'abc@@example.com',
        '.abc@example.com',
        'abc.@example.com',
        'ab..c@example.com',
        'abc@-example.com',
        'abc@example..com',
        '',
      ]) {
        expect(EmailAddress.isValid(email), isFalse, reason: email);
      }
      expect(EmailAddress.isValid(null), isFalse);
    });
  });

  group('EmailAddress.validate', () {
    test('TC_C_EMAIL_003 — a plain message for empty and malformed, '
        'null when fine', () {
      expect(EmailAddress.validate(''), 'Please enter your email address');
      expect(EmailAddress.validate('   '), 'Please enter your email address');
      expect(EmailAddress.validate('abc123'),
          'Please enter a valid email address');
      expect(EmailAddress.validate('parent@example.com'), isNull);
    });
  });
}
