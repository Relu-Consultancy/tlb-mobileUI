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

  /// Overrides the card corner radius. Use 0 for a full-bleed edge-to-edge
  /// banner. When null, falls back to 28 (overlay style) / 14.
  final double? cornerRadius;

  /// When true, the page-dot indicator is overlaid at the bottom of the banner
  /// image (and the external dots row below is removed).
  final bool overlayDots;

  /// When true, each slide scales + fades as it moves through the viewport,
  /// giving a smooth animated transition between carousel images.
  final bool animatedTransition;

  /// When true, the banner stays in a fixed position (no horizontal sliding /
  /// swiping) and the images cross-fade (with a subtle zoom) into one another.
  /// Takes precedence over [animatedTransition].
  final bool staticFade;

  const BannerCarousel({
    super.key,
    required this.events,
    this.height = 220,
    this.showGlow = true,
    this.overlayStyle = false,
    this.ctaText = 'Explore Event',
    this.fixedCardWidth,
    this.cornerRadius,
    this.overlayDots = false,
    this.animatedTransition = false,
    this.staticFade = false,
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
      if (!mounted || widget.events.isEmpty) return;
      final next = (_currentIndex + 1) % widget.events.length;
      if (widget.staticFade) {
        // No sliding — just swap the image; AnimatedSwitcher cross-fades it.
        setState(() => _currentIndex = next);
        return;
      }
      if (_userInteracting || !_pageController.hasClients) return;
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
    final radius = widget.cornerRadius ?? (widget.overlayStyle ? 28.0 : 14.0);

    final indicator = AnimatedSmoothIndicator(
      activeIndex: _currentIndex,
      count: widget.events.length,
      effect: WormEffect(
        dotHeight: 8,
        dotWidth: 8,
        activeDotColor: widget.overlayDots
            ? Colors.white
            : const Color(0xFFFFB902),
        dotColor: widget.overlayDots
            ? Colors.white.withOpacity(0.45)
            : const Color(0xFFE0E0E0),
        spacing: 6,
      ),
    );

    // ── Static cross-fade mode — banner stays put, image fades/zooms in ──
    if (widget.staticFade) {
      return Column(
        children: [
          SizedBox(
            height: widget.height,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 900),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    );
                    return FadeTransition(
                      opacity: curved,
                      // Slide in from the right + zoom out from a slight
                      // close-up, so the image swap feels lively while the
                      // banner itself stays perfectly still.
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.18, 0),
                          end: Offset.zero,
                        ).animate(curved),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.18, end: 1.0)
                              .animate(curved),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: _slide(
                      context,
                      widget.events[_currentIndex],
                      cardWidth,
                      radius,
                    ),
                  ),
                ),
                if (widget.overlayDots)
                  Positioned(bottom: 14, child: indicator),
              ],
            ),
          ),
          if (!widget.overlayDots) ...[
            const SizedBox(height: 12),
            indicator,
          ],
        ],
      );
    }

    return Column(
      children: [
        // ── Swipeable PageView ────────────────────────────────────────
        SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              NotificationListener<ScrollNotification>(
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
                    final card =
                        _slide(context, widget.events[i], cardWidth, radius);
                    if (!widget.animatedTransition) return card;

                    // Scale + fade each slide based on its distance from the
                    // current page for a smooth animated transition.
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double t = 1.0;
                        if (_pageController.position.haveDimensions) {
                          final page =
                              _pageController.page ?? _currentIndex.toDouble();
                          t = (1 - ((page - i).abs() * 0.30)).clamp(0.0, 1.0);
                        }
                        return Transform.scale(
                          scale: 0.94 + t * 0.06, // 0.94 → 1.0 (subtle zoom)
                          child: Opacity(
                            opacity: (0.45 + t * 0.55).clamp(0.0, 1.0), // 0.45 → 1.0
                            child: child,
                          ),
                        );
                      },
                      child: card,
                    );
                  },
                ),
              ),
              // Page dots overlaid at the bottom of the banner image.
              if (widget.overlayDots)
                Positioned(
                  bottom: 14,
                  child: indicator,
                ),
            ],
          ),
        ),

        // ── Shadow image + external dots (skipped when dots are overlaid) ──
        if (!widget.overlayDots) ...[
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
          indicator,
        ],
      ],
    );
  }

  /// Builds a single banner card (background image + optional overlay content).
  Widget _slide(
    BuildContext context,
    EventModel event,
    double cardWidth,
    double radius,
  ) {
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
                          fontWeight: FontWeight.w500,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if ((event.tag ?? '').isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1),
                            ),
                            child: Text(
                              event.tag!,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 11),
                                fontWeight: FontWeight.w500,
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
                            fontWeight: FontWeight.w500,
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
                        if ((event.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            event.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12),
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
                            borderRadius: BorderRadius.circular(30),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailScreen(event: event),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 11),
                              child: Text(
                                widget.ctaText,
                                style: GoogleFonts.poppins(
                                  fontSize: Responsive.sp(context, 14),
                                  fontWeight: FontWeight.w500,
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
  }
}
