import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';

/// Compact three-line meta block shown on section cards: Age Group,
/// Date & Time and Distance. Values come from [EventModel]'s mock display
/// getters for now (swap to real API fields later).
///
/// Designed to drop into the spare space freed up when the review /
/// description rows were removed. Sizing is parameterised so both the small
/// vertical cards and the wider horizontal cards can reuse it.
class ListingMetaRows extends StatelessWidget {
  final EventModel event;
  final double iconSize;
  final double fontSize;
  final double rowGap;

  /// Toggles for callers that already render one of these elsewhere on the
  /// card (e.g. a card that already shows a date badge on the image).
  final bool showAge;
  final bool showDateTime;
  final bool showDistance;

  const ListingMetaRows({
    super.key,
    required this.event,
    this.iconSize = 13,
    this.fontSize = 11,
    this.rowGap = 5,
    this.showAge = true,
    this.showDateTime = true,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      if (showAge) _row(context, Icons.child_care_outlined, event.ageGroupDisplay),
      if (showDateTime)
        _row(context, Icons.calendar_today_outlined, event.dateTimeDisplay),
      if (showDistance)
        _row(context, Icons.near_me_outlined, event.distanceDisplay),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap),
          rows[i],
        ],
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, fontSize),
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
