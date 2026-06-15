import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

class ParentsFavoriteSection extends StatelessWidget {
  const ParentsFavoriteSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('parents_favorite');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.parentsFavorite;
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: "Parents' Favorite",
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: Color(0xFF1A1A2E), // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 400, min: 360),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            addAutomaticKeepAlives: false,
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
                    // Top Image Area — Expanded so the image dominates the
                    // card; flush to the edges with a "Loved by Parents" badge.
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
                          // Top-left "Loved by Parents" gradient badge
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFF53C9B), // pink
                                    Color(0xFFB13CF5), // purple
                                  ],
                                ),
                              ),
                              child: Text(
                                'Loved by Parents',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Content Area — natural height (no CTA; the image
                    // above expands to fill the freed space).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + age range
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 16),
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.people_outline,
                                  size: 14, color: Color(0xFF333333)),
                              const SizedBox(width: 4),
                              Text(
                                event.description ?? '4-12 Yrs',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating: star + value + (reviews)
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 15, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                (event.rating ?? 4.8).toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '(${event.reviewCount ?? '3.5k reviews'})',
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
                    ),
                  ],
                ),
              ));
            },
          ),
        ),
      ],
        );
      },
    );
  }
}
