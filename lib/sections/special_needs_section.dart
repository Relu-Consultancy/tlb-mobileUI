import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';
import '../widgets/shining_star_badge.dart';
import '../widgets/animated_gradient_tag.dart';

class SpecialNeedsSection extends StatelessWidget {
  const SpecialNeedsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('where_every_star_shines');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.specialNeeds;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Where Every Star Shines',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: AppColors.textPrimary, // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 215, min: 195),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length > 1
                ? items.length
                : 3,
            itemBuilder: (context, index) {
              final modelIndex = index % items.length;
              final event = items[modelIndex];
              return Container(
                width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
                margin: const EdgeInsets.only(right: 16),
                // Clip the flush image to the card's rounded corners so it
                // touches the left/top/bottom borders (per reference design).
                clipBehavior: Clip.antiAlias,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left image with red circular star badge
                    SizedBox(
                      width: Responsive.w(context, 215, min: 185),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: listingImage(event.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Shining star badge (top-left) — pink→orange
                          // gradient star with a looping left→right shine.
                          const Positioned(
                            top: 8,
                            left: 8,
                            child: ShiningStarBadge(size: 40),
                          ),
                        ],
                      ),
                    ),
                    // Right content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // "Sensory Friendly" pill — animated pink→purple
                              // gradient that slides continuously (medium pace).
                              if (event.tag != null)
                                AnimatedGradientTag(
                                  text: event.tag!,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  softWrap: false,
                                  showChrome: false,
                                  period: const Duration(seconds: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  borderRadius: BorderRadius.circular(20),
                                  gradientColors: const [
                                    Color(0xFFF53C9B), // pink
                                    Color(0xFFB13CF5), // purple
                                    Color(0xFFF53C9B), // pink (seamless loop)
                                  ],
                                ),
                              const SizedBox(height: 8),
                              // Title
                              Text(
                                event.title,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 17),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Location
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.venue,
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 13),
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Explore button (left-aligned)
                          SizedBox(
                            width: Responsive.w(context, 104, min: 94),
                            height: Responsive.h(context, 30, min: 27),
                            child: ElevatedButton(
                              onPressed: () {
                                openListingDetail(context, event);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'View Now',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 12),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                    ),
                  ],
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
