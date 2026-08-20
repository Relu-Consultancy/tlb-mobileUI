import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/responsive.dart';
import 'detail_sections.dart';

/// "Refundable" / "Non-refundable" row shown on a listing detail page so the
/// customer knows the policy before they pay.
///
/// Built to the same geometry as [DetailTermsRow] — full-width white card,
/// 14pt radius, the same border and horizontal inset — because it sits in that
/// stack. An isolated pill floating on the page background read as an orphan
/// next to those cards.
///
/// This is a label the partner sets, not a rule: marking a listing
/// non-refundable does not currently stop a cancellation from issuing a
/// refund. The copy therefore states the policy and never promises an outcome.
class RefundableBadge extends StatelessWidget {
  final bool isRefundable;

  /// Set false when the row is already inside a horizontally-padded column.
  final bool applyHorizontalPadding;

  const RefundableBadge({
    super.key,
    required this.isRefundable,
    this.applyHorizontalPadding = true,
  });

  static const Color _green = Color(0xFF16A34A);
  static const Color _slate = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    // Non-refundable is a neutral fact, not an error — a red/orange treatment
    // made an ordinary policy look like a warning.
    final Color accent = isRefundable ? _green : _slate;

    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardBorder, width: 0.7),
      ),
      child: Row(
        children: [
          // Bare icon at the same size and gap as DetailTermsRow, so the text
          // in this row starts at the same x as the rows beneath it. A tinted
          // tile looked good alone but pushed the label 14pt out of line.
          Icon(
            isRefundable
                ? Icons.verified_outlined
                : Icons.do_not_disturb_alt_outlined,
            size: 24,
            color: accent,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isRefundable ? 'Refundable' : 'Non-refundable',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 14),
                    fontWeight: FontWeight.w600,
                    color: kDetailText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isRefundable
                      ? 'Cancel before the cutoff to request a refund'
                      : 'The organiser has marked this listing non-refundable',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11.5),
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!applyHorizontalPadding) return row;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: row,
    );
  }
}
