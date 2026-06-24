import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';

/// Compact meta block shown on section cards: Age Group, Date & Time, Distance
/// and (optionally) Location. Values come from [EventModel]'s mock display
/// getters for now (swap to real API fields later).
///
/// Two layouts:
///  - single column (default) — a stack of rows, used by compact cards.
///  - [twoColumn] — an aligned 2×N grid: each row has a left cell (Age /
///    Date·Time) and a right cell (Location / Distance), so the columns line up
///    evenly. Used by the larger vertical cards.
///
/// Distance is rendered in green (like an "● Open" status tag).
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

  /// Render the listing's location (`event.venue`). In the two-column layout it
  /// anchors the right column.
  final bool showLocation;

  /// Split the meta evenly into an aligned two-column grid (Age/Date on the
  /// left, Location/Distance on the right).
  final bool twoColumn;

  /// Green used for the distance "tag".
  static const Color _distanceGreen = Color(0xFF1FA85B);

  const ListingMetaRows({
    super.key,
    required this.event,
    this.iconSize = 13,
    this.fontSize = 11,
    this.rowGap = 5,
    this.showAge = true,
    this.showDateTime = true,
    this.showDistance = true,
    this.showLocation = false,
    this.twoColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    if (twoColumn) {
      // Left column cells (Age, Date·Time) paired row-by-row with the right
      // column cells (Location, Distance) so the two columns stay aligned.
      final left = <Widget>[
        if (showAge)
          _row(context, Icons.child_care_outlined, event.ageGroupDisplay),
        if (showDateTime)
          _row(context, Icons.calendar_today_outlined, event.dateTimeDisplay),
      ];
      final right = <Widget>[
        if (showLocation)
          _row(context, Icons.location_on_outlined, event.venue,
              alignEnd: true),
        if (showDistance)
          _row(context, Icons.near_me_outlined, event.distanceDisplay,
              color: _distanceGreen, alignEnd: true),
      ];
      final int rowCount = left.length > right.length ? left.length : right.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < rowCount; i++) ...[
            if (i > 0) SizedBox(height: rowGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: i < left.length ? left[i] : const SizedBox.shrink()),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        i < right.length ? right[i] : const SizedBox.shrink()),
              ],
            ),
          ],
        ],
      );
    }

    return _column(<Widget>[
      if (showLocation) _row(context, Icons.location_on_outlined, event.venue),
      if (showAge)
        _row(context, Icons.child_care_outlined, event.ageGroupDisplay),
      if (showDateTime)
        _row(context, Icons.calendar_today_outlined, event.dateTimeDisplay),
      if (showDistance)
        _row(context, Icons.near_me_outlined, event.distanceDisplay,
            color: _distanceGreen),
    ]);
  }

  Widget _column(List<Widget> rows) {
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

  Widget _row(BuildContext context, IconData icon, String text,
      {Color? color, bool alignEnd = false}) {
    final Color c = color ?? AppColors.textSecondary;
    final Widget label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: Responsive.sp(context, fontSize),
        color: c,
        fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    return Row(
      // When [alignEnd], the icon+text group hugs the right edge of its cell so
      // the right column lines up flush with the CTA button's right edge.
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: iconSize, color: c),
        const SizedBox(width: 4),
        // Flexible (not Expanded) when right-aligned so the group only takes the
        // width it needs and stays pinned to the right, still ellipsising if long.
        alignEnd ? Flexible(child: label) : Expanded(child: label),
      ],
    );
  }
}
