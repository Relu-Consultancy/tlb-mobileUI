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

/// Shared geometry for a field's leading icon — inset from the field's own
/// left edge, its size, and the gap before the text that follows it.
///
/// A phone field using [IndianDialBadge] zeroes `prefixIconConstraints` so
/// its icon can sit flush at these numbers; a sibling field that leaves them
/// at Material's default gets a 48x48 icon box instead, and its placeholder
/// lands several pixels further right. Sharing the numbers — and, per field,
/// subtracting back out the extra gap Material's `InputDecorator` inserts
/// between `prefixIcon` and the input (see `_kDecoratorPrefixGap` at each
/// call site) — is what keeps a stack of fields reading as one column.
class IndianDialPrefix {
  const IndianDialPrefix._();

  static const double inset = 14;
  static const double gap = 8;
  static const double iconSize = 20;

  /// The x at which the first glyph of text sits in any field using this
  /// geometry — a placeholder, a typed value, or the digits in a phone field
  /// once [IndianDialBadge] moves "+91" out of this row entirely.
  static const double textOffset = inset + iconSize + gap;
}

/// Floats a "+91" badge over [child]'s top-left corner instead of showing the
/// dial code inline before the digits.
///
/// A dial code shown inline unavoidably claims some of the field's own
/// leading width — there is no size small enough to keep "+91" legible and
/// still let the digits start where every sibling field's text does (at
/// [IndianDialPrefix.textOffset]). [child] therefore carries no dial code at
/// all; it is a plain field, with the exact same leading icon every other
/// field in the form uses. This widget adds "+91" back as a small label
/// overlapping the field's top border — visible, but outside the row that
/// decides where the digits begin.
class IndianDialBadge extends StatelessWidget {
  final Widget child;

  const IndianDialBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          left: IndianDialPrefix.inset - 5,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              IndianPhone.dialCode,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 10.5),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
