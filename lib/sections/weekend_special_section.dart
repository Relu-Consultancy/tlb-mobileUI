import '../core/responsive.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/listing_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/wishlist_button.dart';
import '../widgets/section_divider_widget.dart';
import '../providers/home_feed_state.dart';
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
      final wk = HomeFeedState.section('weekend_specials');
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
        final items = HomeFeedState.section('weekend_specials');
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(
          title: 'Weekend Specials',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          textColor: Color(0xFF1A1A2E), // dark navy
        ),
        SizedBox(
          height: Responsive.h(context, 200, min: 180),
          child: PageView.builder(
            controller: _pageController,
            clipBehavior: Clip.hardEdge,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final event = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left Image Area
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                                child: listingImage(event.imagePath,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Heart icon (top-left)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: WishlistButton(event: event, showShadow: true),
                            ),
                          ],
                        ),
                      ),

                      // Right Content Area
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 14),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Date
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Saturday, 27 Apr\n| 10:00 AM',
                                          style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 11),
                                            color: Colors.grey.shade600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Venue
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.venue,
                                          style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 11),
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // Book Now button
                              SizedBox(
                                width: double.infinity,
                                height: Responsive.h(context, 34, min: 30),
                                child: ElevatedButton(
                                  onPressed: () {
                                    openListingDetail(context, event);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFCC00),
                                    foregroundColor: const Color(0xFF1A1A2E),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Book Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 12),
                                      fontWeight: FontWeight.w600,
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
        const SizedBox(height: 16),
      ],
        );
      },
    );
  }
}
