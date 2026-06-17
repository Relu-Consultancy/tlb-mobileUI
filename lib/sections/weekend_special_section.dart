import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
import '../data/dummy_data.dart';
import '../core/listing_navigation.dart';

class WeekendSpecialSection extends StatefulWidget {
  const WeekendSpecialSection({super.key});

  @override
  State<WeekendSpecialSection> createState() => _WeekendSpecialSectionState();
}

class _WeekendSpecialSectionState extends State<WeekendSpecialSection> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      // final wk = HomeFeedState.section('weekend_specials');
      final wk = DummyData.weekendSpecial;
      if (!_pageController.hasClients || wk.isEmpty) return;
      final nextPage = ((_pageController.page?.round() ?? 0) + 1) % wk.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: HomeFeedState.version,
      builder: (context, _, __) {
        // ── Reverted to mock data — API wiring commented out (re-enable later) ──
        // final items = HomeFeedState.section('weekend_specials');
        // if (items.isEmpty) return const SizedBox.shrink();
        final items = DummyData.weekendSpecial;
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionDividerWidget(
              title: 'Weekend Specials',
              topPadding: 30, // 30px gap from previous section's cards
              fontSize: 17,
              fontWeight: FontWeight.w600,
              textColor: AppColors.textPrimary, // dark navy
            ),
            SizedBox(
              height: Responsive.h(context, 365, min: 340),
              child: PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.hardEdge,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final event = items[index];
                  // `tag` carries the two-line date badge, e.g. "Sun\nmar 17".
                  final dateParts = (event.tag ?? '').split('\n');
                  final dayStr = dateParts.isNotEmpty ? dateParts[0] : '';
                  final dateStr = dateParts.length > 1 ? dateParts[1] : '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.1), width: 0.7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Top image with date badge + heart ──
                          SizedBox(
                            height: Responsive.h(context, 240, min: 222),
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: listingImage(event.imagePath,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Date badge (top-left)
                                if (dayStr.isNotEmpty)
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.10),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            dayStr,
                                            style: GoogleFonts.poppins(
                                              fontSize: Responsive.sp(context, 13),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            dateStr,
                                            style: GoogleFonts.poppins(
                                              fontSize: Responsive.sp(context, 12),
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accentBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Heart (top-right)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: WishlistButton(
                                    event: event,
                                    containerSize: 36,
                                    showShadow: true,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Content ──
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Title
                                  Text(
                                    event.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 17),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // Rating: 5 stars + review count
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (_) => const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        event.reviewCount ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: Responsive.sp(context, 13),
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Venue + Book Now
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 15, color: AppColors.textSecondary),
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
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: Responsive.h(context, 30, min: 27),
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              openListingDetail(context, event),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryLight,
                                            foregroundColor: AppColors.textPrimary,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: Text(
                                            'Book Now',
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Dot indicators
            Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: items.length,
                effect: const WormEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: Color(0xFFDE7104),
                  dotColor: Color(0xFFE0E0E0),
                  spacing: 6,
                ),
              ),
            ),
            // Trailing space removed — the next section's 30px topPadding
            // provides the gap below the dots indicator.
          ],
        );
      },
    );
  }
}
