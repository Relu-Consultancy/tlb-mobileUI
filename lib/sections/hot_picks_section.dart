import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import '../widgets/section_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

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
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Hot Picks',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          fontWeight: FontWeight.w600,
          textColor: Color(0xFF1A1A2E), // dark navy
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
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                
                                // Age Range Row
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline, size: 14, color: Color(0xFF333333)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '3-5 Yrs', // Dummy age range
                                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Color(0xFF333333)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Reviews Row
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => const Icon(Icons.star, size: 12, color: Colors.amber),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        event.reviewCount ?? '3.5k reviews',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Color(0xFF333333)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Venue Row
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF333333)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        event.venue,
                                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Color(0xFF333333)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
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
            },
          ),
        ),
      ],
        );
      },
    );
  }
}
