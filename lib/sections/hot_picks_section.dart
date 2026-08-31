import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/listing_meta_rows.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';
import 'package:showcaseview/showcaseview.dart';
import '../helpers/walkthrough_keys.dart';
import '../widgets/walkthrough_tooltip.dart';

class HotPicksSection extends StatelessWidget {
  const HotPicksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('hot_picks');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.hotPicks;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Hot Picks',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          fontWeight: FontWeight.w600,
          textColor: AppColors.textPrimary, // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 440, min: 395),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (context, index) {
              final event = items[index];
              final card = GestureDetector(
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
                    // Top Image Area — flush to the card edges (no margin);
                    // top corners follow the card's rounded border. Expanded
                    // so the image takes up the majority of the card; the
                    // content below sizes to its natural height.
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: listingImage(event.imagePath,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Top-left floating badge (Filling Fast / Bestseller)
                          // TEMPORARILY DISABLED — `event.tag` currently carries
                          // the raw category string from the API. Re-enable once
                          // the tag/category value is cleaned up.
                          /*
                          if (event.tag != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    colors: event.tag?.toLowerCase() == 'filling fast'
                                        ? [const Color(0xFF5C79E8), const Color(0xFF384B99)] // Blue gradient
                                        : [const Color(0xFFE85C79), const Color(0xFF99384B)], // Red gradient
                                  ),
                                ),
                                child: Text(
                                  event.tag ?? 'Filling Fast',
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          */
                          ],
                        ),
                      ),

                    // Bottom Content Area — natural height (sizes to fit).
                    Padding(
                      // 18px gap below the content (card bottom padding).
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
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
                                const SizedBox(height: 8),

                                // Two-column meta: Age + Date·Time left,
                                // Location + Distance right.
                                ListingMetaRows(
                                  event: event,
                                  showLocation: true,
                                  twoColumn: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                ),
              );

              // The tour's "Tap Any Card" step points at the very first
              // card — teaching the interaction once, on a concrete example,
              // rather than on every card in every section.
              if (index == 0) {
                return Showcase.withWidget(
                  key: WalkthroughKeys.firstSectionCard,
                  targetShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  blurValue: 3,
                  overlayOpacity: 0.6,
                  targetPadding: const EdgeInsets.all(4),
                  targetTooltipGap: 14,
                  // The card lives below the hero, off-screen at tour start —
                  // scroll it into view rather than requiring the card to
                  // already be visible for its own step to make sense.
                  enableAutoScroll: true,
                  scrollAlignment: 0.3,
                  container: WalkthroughTooltip(
                    icon: kSectionCardShowcaseConfig.icon,
                    title: kSectionCardShowcaseConfig.title,
                    description: kSectionCardShowcaseConfig.description,
                    stepIndex: kSectionCardShowcaseConfig.stepIndex,
                    totalSteps: WalkthroughKeys.totalSteps,
                    onNext: () => ShowcaseView.get().next(),
                    onSkip: () => ShowcaseView.get().dismiss(),
                  ),
                  child: card,
                );
              }
              return card;
            },
          ),
        ),
      ],
        );
      },
    );
  }
}
