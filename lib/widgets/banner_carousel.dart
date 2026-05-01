import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/responsive.dart';
import '../models/event_model.dart';
import 'wishlist_button.dart';
import '../screens/event_detail_screen.dart';

class BannerCarousel extends StatefulWidget {
  final List<EventModel> events;
  final double height;
  final bool showGlow;
  final bool overlayStyle;
  final String ctaText;

  const BannerCarousel({
    super.key,
    required this.events,
    this.height = 220,
    this.showGlow = true,
    this.overlayStyle = false,
    this.ctaText = 'Explore Event',
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
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
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients || widget.events.isEmpty) return;
      final nextPage = ((_pageController.page?.round() ?? 0) + 1) %
          widget.events.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: widget.height,
              child: PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.hardEdge,
                itemCount: widget.events.length,
                itemBuilder: (context, index) {
                  final event = widget.events[index];
                  // KEY CHANGE: bigger radius in overlay mode
                  final radius = widget.overlayStyle ? 28.0 : 14.0;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ClipRRect(
                        // KEY CHANGE: fully-clipped rounded container (~28px for events)
                        borderRadius: BorderRadius.circular(radius),
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Background image — clipped by ClipRRect above
                            Image.asset(
                              event.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade200,
                                        Colors.orange.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(radius),
                                  ),
                                  child: Center(
                                    child: Text(
                                      event.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 22),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // KEY CHANGE: dark top→bottom gradient overlay for text legibility
                            if (widget.overlayStyle)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.05),
                                        Colors.black.withOpacity(0.20),
                                        Colors.black.withOpacity(0.55),
                                      ],
                                      stops: const [0.25, 0.55, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                            // Overlay title + optional tag badge + subtitle + pill CTA
                            if (widget.overlayStyle)
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 24,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Optional tag badge (e.g. "EDUCATION")
                                    if ((event.tag ?? '').isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                                        ),
                                        child: Text(
                                          event.tag!,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    Text(
                                      event.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: Responsive.sp(context, 24),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black45,
                                            offset: Offset(0, 2),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Optional subtitle (event.description)
                                    if ((event.description ?? '').isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        event.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.88),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    // Pill-shaped yellow CTA
                                    Material(
                                      color: const Color(0xFFFFCC00),
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EventDetailScreen(event: event),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 22,
                                            vertical: 11,
                                          ),
                                          child: Text(
                                            widget.ctaText,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1A1A2E),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Wishlist heart — hidden in overlay mode to match the design
                            if (!widget.overlayStyle)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: WishlistButton(event: event),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Warm glow strip — bleeds below the card (home page only)
            if (widget.showGlow)
              Positioned(
                bottom: -6,
                left: 28,
                right: 28,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8831A).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8831A).withOpacity(0.55),
                        blurRadius: 22,
                        spreadRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: widget.showGlow ? 18 : 12),
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.events.length,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Color(0xFFFFB902),
            dotColor: Color(0xFFE0E0E0),
            spacing: 6,
          ),
        ),
      ],
    );
  }
}
