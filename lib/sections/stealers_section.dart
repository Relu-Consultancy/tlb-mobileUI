import '../core/responsive.dart';
import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

class StealersSection extends StatelessWidget {
  const StealersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('stealers');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.stealers;
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Stealers',
          topPadding: 30, // 30px gap from previous section's cards
          fontSize: 17,
          textColor: Color(0xFF1A1A2E), // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 420, min: 380),
          child: AutoScrollList(
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final event = items[index];
              return Container(
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
                    // card; flush to the edges, with the countdown pill at the
                    // top and the discount band at the bottom.
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
                          // Top yellow countdown pill ("End in ...")
                          if (event.description != null)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFF176), // light yellow
                                        Color(0xFFFFEE58),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(12)),
                                  ),
                                  child: Text(
                                    event.description!,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Bottom pink discount band ("60% OFF")
                          if (event.tag != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE040FB), // bright pink
                                      Color(0xFFEA80FC), // lighter pink-purple
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                child: Text(
                                  event.tag!,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Bottom Content Area — kept tight so the image above
                    // stretches further down (less white space).
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 17),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Stars + review count
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                event.reviewCount ?? '3.5k reviews',
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 13),
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Grab Deal button (price label removed)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              SizedBox(
                                height: Responsive.h(context, 30, min: 27),
                                child: ElevatedButton(
                                  onPressed: () {
                                    openListingDetail(context, event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFCC00),
                                    foregroundColor: const Color(0xFF1A1A2E),
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        ],
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
