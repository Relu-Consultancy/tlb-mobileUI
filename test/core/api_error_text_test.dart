import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/api_error_text.dart';

void main() {
  group('ApiErrorText.readable', () {
    test(
        'TC_C_ERR_001 — the stringified validation error from request-otp '
        '(bug_login_001) becomes its message', () {
      // Verbatim from the live API for identifier "abc123".
      const raw = "{'identifier': [ErrorDetail(string='Enter a valid email "
          "address.', code='invalid')]}";
      expect(ApiErrorText.readable(raw), 'Enter a valid email address.');
    });

    test('TC_C_ERR_002 — Python double quotes and escapes are handled', () {
      const raw = '''{'name': [ErrorDetail(string="Don't use \\"quotes\\".", code='invalid')]}''';
      expect(ApiErrorText.readable(raw), 'Don\'t use "quotes".');
      expect(
        ApiErrorText.readable(
            "[ErrorDetail(string='Invalid coupon.', code='invalid')]"),
        'Invalid coupon.',
      );
    });

    test('TC_C_ERR_003 — a generic "This field" message names the field', () {
      expect(
        ApiErrorText.readable("{'first_name': [ErrorDetail(string='This field "
            "may not be blank.', code='blank')]}"),
        'First name may not be blank.',
      );
      expect(
        ApiErrorText.readable("{'identifier': [ErrorDetail(string='This field "
            "is required.', code='required')]}"),
        'Email is required.',
      );
    });

    test('TC_C_ERR_004 — plain messages are left alone', () {
      expect(ApiErrorText.readable('Account not found.'), 'Account not found.');
      expect(ApiErrorText.readable('  OTP has expired.  '), 'OTP has expired.');
    });

    test('TC_C_ERR_005 — anything else code-shaped never reaches the screen',
        () {
      for (final raw in [
        "{'detail': 'oops'}",
        '[1, 2, 3]',
        'Traceback (most recent call last): ...',
        'ValueError Exception: bad',
        '<html><body>502 Bad Gateway</body></html>',
        '',
        '   ',
      ]) {
        expect(ApiErrorText.readable(raw), ApiErrorText.fallback, reason: raw);
      }
    });
  });

  group('ApiErrorText.field', () {
    test('TC_C_ERR_006 — drops the raw field key', () {
      expect(ApiErrorText.field('phone_number', 'Enter a valid phone number.'),
          'Enter a valid phone number.');
      expect(ApiErrorText.field('rating', 'This field is required.'),
          'Rating is required.');
      expect(ApiErrorText.field('non_field_errors', 'This field is odd.'),
          'This field is odd.');
    });
  });
}
