import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'responsive.dart';

/// Validation and input rules for Indian mobile numbers.
///
/// A mobile number here is exactly **10 digits starting 6–9**. Landlines and
/// short codes are deliberately not accepted: every field using this asks for
/// a contact the organiser can reach the customer on.
class IndianPhone {
  const IndianPhone._();

  static const String dialCode = '+91';
  static const int length = 10;

  /// Only digits are typeable, capped at 10, so an invalid number is largely
  /// unreachable rather than merely rejected after the fact.
  static List<TextInputFormatter> get inputFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ];

  /// Strips formatting and any country prefix the user pasted in, so
  /// "+91 98765 43210", "091-9876543210" and "9876543210" all normalise to the
  /// same ten digits.
  static String normalise(String? raw) {
    var digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length > length && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (digits.length > length && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  static bool isValid(String? raw) {
    final d = normalise(raw);
    return d.length == length && RegExp(r'^[6-9]').hasMatch(d);
  }

  /// Message for an invalid number, or null when it is fine.
  ///
  /// [required] false lets an empty field pass — used where the number is
  /// optional but must still be valid if given.
  static String? validate(String? raw, {bool required = true}) {
    final d = normalise(raw);
    if (d.isEmpty) {
      return required ? 'Please enter a mobile number.' : null;
    }
    if (d.length < length) {
      return 'Enter all $length digits (${d.length} so far).';
    }
    if (d.length > length) return 'A mobile number is $length digits.';
    if (!RegExp(r'^[6-9]').hasMatch(d)) {
      return 'An Indian mobile number starts with 6, 7, 8 or 9.';
    }
    return null;
  }

  /// Number in the form the API expects.
  static String e164(String? raw) => '$dialCode${normalise(raw)}';
}

/// The fixed "+91" shown at the head of a phone field.
///
/// Used on the fields that have no country picker of their own. Where a picker
/// already exists (Edit Profile) that stays — this is not a replacement for it.
class IndianDialPrefix extends StatelessWidget {
  /// Matches the surrounding field's text colour.
  final Color? color;

  /// Optional leading glyph, kept so a field that already had a phone icon
  /// does not lose it — its siblings keep theirs, and dropping it here alone
  /// would make the row look unlike the fields around it.
  final IconData? icon;

  const IndianDialPrefix({super.key, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 8),
          ],
          Text(
            IndianPhone.dialCode,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFF262626),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 20, color: const Color(0xFFDDDDE3)),
        ],
      ),
    );
  }
}
