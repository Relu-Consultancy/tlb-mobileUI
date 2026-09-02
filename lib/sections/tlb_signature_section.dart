import 'dart:math' as math;

import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/listing_meta_rows.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';
import '../widgets/animated_gradient_tag.dart';

/// Space between the poster panel and the card edge. The content below uses
/// the same value, so the card carries one even frame on every side and the
/// title lines up with the poster's left edge instead of sitting 4px inside it.
const double _kImageInset = 12;

/// Corner radius of the inset poster. Deliberately larger than the strictly
/// concentric value (card radius 16 − inset 12 = 4), which reads as a hard
/// square at this size.
const double _kImageRadius = 12;

class TlbSignatureSection extends StatelessWidget {
  const TlbSignatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('tlb_signature');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.tlbSignature;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'TLB Signature',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: AppColors.textPrimary, // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 480, min: 430),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final event = items[index];
              return GestureDetector(
                onTap: () => openListingDetail(context, event),
                child: Container(
                width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Image Area — the poster is an inset, fully-rounded
                    // panel rather than a bleed to the card edge, so it sits
                    // symmetrically inside the card: the same _kImageInset on
                    // its left, right and top, and the content padding below
                    // lines up with it. Matches the inset-image treatment used
                    // by Build New Skills and Easy on the Pocket.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          _kImageInset,
                          _kImageInset,
                          _kImageInset,
                          0,
                        ),
                        // One clip around the whole stack, so the sash is cut
                      // flush by the same rounded corner as the poster.
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(_kImageRadius),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: listingImage(event.imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // "TLB Originals" sash, running diagonally across
                            // the poster's top-left corner.
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _DiagonalSash(
                                text: 'TLB Originals',
                                span: Responsive.w(context, 96, min: 86),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),

                    // Bottom Content — natural height, inset to match the
                    // poster so the frame is even all the way round.
                    Padding(
                      padding: const EdgeInsets.all(_kImageInset),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          // Age Group · Date & Time · Distance (mock data)
                          ListingMetaRows(event: event),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              );
            },
          ),
        ),
      ],
        );
      },
    );
  }
}

/// A ribbon running diagonally across a corner, with its label set along the
/// diagonal — the classic "sash" treatment.
///
/// Sized as a [span]×[span] box pinned to the corner it crosses. The band is
/// laid out horizontally, then rotated 45° anticlockwise about its own centre,
/// which is placed at the midpoint of the diagonal (`span/2`, `span/2`). The
/// band is deliberately longer than the diagonal it spans so both ends bleed
/// past the corner and get cut flush by the parent's clip, rather than
/// stopping short and showing their squared-off ends.
class _DiagonalSash extends StatelessWidget {
  final String text;

  /// How far along each edge, measured from the corner, the sash crosses.
  final double span;

  const _DiagonalSash({required this.text, required this.span});

  @override
  Widget build(BuildContext context) {
    final bandHeight = Responsive.h(context, 25, min: 23);
    // √2 would exactly reach the corner's edges; the extra covers the band's
    // own thickness at the ends and guarantees a flush cut.
    final length = span * 1.75;

    return SizedBox(
      width: span,
      height: span,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: span / 2 - length / 2,
            top: span / 2 - bandHeight / 2,
            child: Transform.rotate(
              // Negative is anticlockwise, so the band rises left→right and
              // the label reads bottom-left to top-right.
              angle: -math.pi / 4,
              child: SizedBox(
                width: length,
                height: bandHeight,
                child: AnimatedGradientTag(
                  text: text,
                  fontSize: 11,
                  // A sash is a flat band across the artwork; the pill's white
                  // outline and drop shadow only read on a floating chip.
                  showChrome: false,
                  softWrap: false,
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
