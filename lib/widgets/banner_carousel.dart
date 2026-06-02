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
  final double? fixedCardWidth;

  const BannerCarousel({
    super.key,
    required this.events,
    this.height = 220,
    this.showGlow = true,
    this.overlayStyle = false,
    this.ctaText = 'Explore Event',
    this.fixedCardWidth,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  late final PageController _pageController;
  // True while the user is actively swiping — pauses auto-advance so the
  // timer doesn't fight the gesture.
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted ||
          widget.events.isEmpty ||
          _userInteracting ||
          !_pageController.hasClients) {
        return;
      }
      final next = (_currentIndex + 1) % widget.events.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = widget.fixedCardWidth ?? (screenWidth * 0.92 - 12);
    final radius = widget.overlayStyle ? 28.0 : 14.0;

    return Column(
      children: [
        // ── Swipeable PageView ────────────────────────────────────────
        SizedBox(
          height: widget.height,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification) {
                _userInteracting = true;
              } else if (n is ScrollEndNotification) {
                _userInteracting = false;
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.events.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (ctx, i) {
                final event = widget.events[i];
                return Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    ),
                    child: SizedBox(
                      width: cardWidth,
                      height: widget.height,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Background image
                            Image.asset(
                              event.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
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
                              ),
                            ),

                            // Dark gradient overlay (overlayStyle only)
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

                            // Title + tag + CTA (overlayStyle only)
                            if (widget.overlayStyle)
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 24,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if ((event.tag ?? '').isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.5),
                                              width: 1),
                                        ),
                                        child: Text(
                                          event.tag!,
                                          style: GoogleFonts.poppins(
                                            fontSize:
                                                Responsive.sp(context, 11),
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
                                    if ((event.description ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        event.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize:
                                              Responsive.sp(context, 12),
                                          color: Colors.white.withOpacity(0.88),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    Material(
                                      color: const Color(0xFFFFCC00),
                                      borderRadius: BorderRadius.circular(30),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(30),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EventDetailScreen(
                                                event: event),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22, vertical: 11),
                                          child: Text(
                                            widget.ctaText,
                                            style: GoogleFonts.poppins(
                                              fontSize:
                                                  Responsive.sp(context, 14),
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

                            // Wishlist heart (non-overlay mode only)
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
                  ),
                );
              },
            ),
          ),
        ),

        // ── Shadow image (showGlow screens only) ───────────────────
        if (widget.showGlow) ...[
          const SizedBox(height: 8),
          Image.asset(
            'resources- tlb-ui/shadow_underneath.png',
            width: cardWidth,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 6),
        ] else
          const SizedBox(height: 12),

        // ── Dot indicator ───────────────────────────────────────────
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
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
