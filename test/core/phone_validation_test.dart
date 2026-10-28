import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/phone_validation.dart';

void main() {
  group('IndianPhone.isValid', () {
    test('TC_C_PH_001 — accepts a 10-digit number starting 6-9', () {
      for (final n in ['9876543210', '8000000000', '7012345678', '6123456789']) {
        expect(IndianPhone.isValid(n), isTrue, reason: n);
      }
    });

    test('TC_C_PH_002 — rejects a number starting 0-5', () {
      for (final n in ['5876543210', '1234567890', '0987654321']) {
        expect(IndianPhone.isValid(n), isFalse, reason: n);
      }
    });

    test('TC_C_PH_003 — rejects the wrong number of digits', () {
      expect(IndianPhone.isValid('98765'), isFalse);
      expect(IndianPhone.isValid('987654321'), isFalse); // 9
      expect(IndianPhone.isValid(''), isFalse);
      expect(IndianPhone.isValid(null), isFalse);
    });
  });

  group('IndianPhone.normalise', () {
    // A pasted number often carries a country code or spacing.
    test('TC_C_PH_004 — strips a +91 prefix and formatting', () {
      expect(IndianPhone.normalise('+91 98765 43210'), '9876543210');
      expect(IndianPhone.normalise('+91-9876543210'), '9876543210');
      expect(IndianPhone.normalise('919876543210'), '9876543210');
      expect(IndianPhone.normalise('(987) 654-3210'), '9876543210');
    });

    test('TC_C_PH_005 — strips a leading trunk zero', () {
      expect(IndianPhone.normalise('09876543210'), '9876543210');
    });

    // 9 is a valid leading digit, so a bare 10-digit number starting 91 must
    // not have those two stripped as a country code.
    test('TC_C_PH_006 — does not eat a leading 91 from a 10-digit number', () {
      expect(IndianPhone.normalise('9187654321'), '9187654321');
      expect(IndianPhone.isValid('9187654321'), isTrue);
    });
  });

  group('IndianPhone.validate', () {
    test('TC_C_PH_007 — an empty required field asks for a number', () {
      expect(IndianPhone.validate(''), 'Please enter a mobile number.');
    });

    test('TC_C_PH_008 — an empty optional field passes', () {
      expect(IndianPhone.validate('', required: false), isNull);
    });

    test('TC_C_PH_009 — a partial number counts the digits so far', () {
      expect(IndianPhone.validate('98765'), 'Enter all 10 digits (5 so far).');
    });

    test('TC_C_PH_010 — a bad leading digit says which are allowed', () {
      expect(
        IndianPhone.validate('1234567890'),
        'An Indian mobile number starts with 6, 7, 8 or 9.',
      );
    });

    test('TC_C_PH_011 — a valid number returns no error', () {
      expect(IndianPhone.validate('9876543210'), isNull);
      expect(IndianPhone.validate('+91 98765 43210'), isNull);
    });
  });

  group('Input rules', () {
    test('TC_C_PH_012 — only digits are typeable, capped at 10', () {
      final formatters = IndianPhone.inputFormatters;
      expect(formatters.whereType<FilteringTextInputFormatter>(), isNotEmpty);
      expect(
        formatters.whereType<LengthLimitingTextInputFormatter>().first.maxLength,
        10,
      );
    });

    test('TC_C_PH_013 — e164 renders the number the API form', () {
      expect(IndianPhone.e164('9876543210'), '+919876543210');
      expect(IndianPhone.e164('+91 98765 43210'), '+919876543210');
    });
  });
}
