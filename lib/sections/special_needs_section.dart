import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';
import '../widgets/shining_star_badge.dart';

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
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Where Every Star Shines',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: Color(0xFF1A1A2E), // dark navy
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
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // "Sensory Friendly" pink pill (left-aligned)
                              if (event.tag != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF53C9B), // pink
                                        Color(0xFFB13CF5), // purple
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    event.tag!,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.visible,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 10),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Title
                              Text(
                                event.title,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 17),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 15, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.reviewCount ?? '4.5k reviews',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 13),
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Location
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: Color(0xFF333333)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.venue,
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 13),
                                        color: Color(0xFF333333),
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
                                backgroundColor: const Color(0xFFFFCC00),
                                foregroundColor: const Color(0xFF1A1A2E),
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
