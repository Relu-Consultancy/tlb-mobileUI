import 'dart:async';
import 'dart:math' as math;
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

  /// When true, a ~4px golden gradient border sweeps continuously (medium
  /// pace) around each banner card.
  final bool animatedGoldenBorder;

  /// Fraction of the viewport each page occupies. Values below 1.0 reveal the
  /// previous/next banners peeking at the left and right edges (carousel
  /// look). When set, the card width is derived from the page width and
  /// [fixedCardWidth] is ignored.
  final double? viewportFraction;

  /// When true, each banner image gets a subtle, continuous Ken Burns motion
  /// (slow zoom + drifting pan) so the banner feels alive.
  final bool animateImages;

  /// When true, the carousel scrolls endlessly — after the last card it keeps
  /// advancing forward into the first (no rewind back to the start).
  final bool infiniteScroll;

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
    this.animatedGoldenBorder = false,
    this.viewportFraction,
    this.animateImages = false,
    this.infiniteScroll = false,
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

  // Large base page for the endless loop: a multiple of the event count, so
  // the first shown card is index 0 and there's room to advance "forever".
  int get _loopBase =>
      widget.events.isEmpty ? 0 : widget.events.length * 1000;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.infiniteScroll ? _loopBase : 0;
    _pageController = PageController(
      viewportFraction: widget.viewportFraction ?? 1.0,
      initialPage: _currentIndex,
    );
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
      if (widget.staticFade) {
        // No sliding — just swap the image; AnimatedSwitcher cross-fades it.
        setState(() =>
            _currentIndex = (_currentIndex + 1) % widget.events.length);
        return;
      }
      if (_userInteracting || !_pageController.hasClients) return;
      if (widget.infiniteScroll) {
        // Always advance forward — endless cycle, never rewinds to page 0.
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
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
    // In peek mode the card fills its (narrower) page, leaving a small gap so
    // the neighbouring banners show as rounded slivers on each side.
    final cardWidth = widget.viewportFraction != null
        ? screenWidth * widget.viewportFraction! - 14
        : (widget.fixedCardWidth ?? (screenWidth * 0.92 - 12));
    final radius = widget.cornerRadius ?? (widget.overlayStyle ? 28.0 : 14.0);

    final indicator = AnimatedSmoothIndicator(
      activeIndex: widget.infiniteScroll
          ? _currentIndex % widget.events.length
          : _currentIndex,
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
                  // Endless loop uses a very large virtual count with a modulo
                  // lookup; otherwise a plain count.
                  itemCount: widget.infiniteScroll
                      ? widget.events.length * 2000
                      : widget.events.length,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemBuilder: (ctx, i) {
                    final event =
                        widget.events[i % widget.events.length];
                    final card = _slide(context, event, cardWidth, radius);

                    // Peek carousel — shrink the side (neighbouring) cards so
                    // the centred banner stands out larger than the ones
                    // peeking at the edges. Each side card is scaled toward its
                    // VISIBLE edge so the peeking sliver stays put (otherwise
                    // shrinking toward the off-screen centre hides the peek).
                    if (widget.viewportFraction != null) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double rel = 0.0; // <0 = left side, >0 = right side
                          if (_pageController.position.haveDimensions) {
                            final page = _pageController.page ??
                                _currentIndex.toDouble();
                            rel = (i - page).clamp(-1.0, 1.0);
                          }
                          final diff = rel.abs();
                          // Centre card = 1.0, full neighbour = 0.84.
                          final scale = 1.0 - diff * 0.16;
                          // Right neighbour anchors on its left edge, left
                          // neighbour on its right edge — keeps the peek width.
                          final alignment = rel >= 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight;
                          return Transform.scale(
                            scale: scale,
                            alignment: alignment,
                            child: child,
                          );
                        },
                        child: card,
                      );
                    }

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

  /// Wraps [child] in a subtle Ken Burns motion when [animateImages] is set.
  Widget _kenBurns(Widget child) =>
      widget.animateImages ? _KenBurnsImage(child: child) : child;

  /// Builds a single banner card (background image + optional overlay content).
  Widget _slide(
    BuildContext context,
    EventModel event,
    double cardWidth,
    double radius,
  ) {
    final card = Container(
          width: cardWidth,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            // Very slim border around the spotlight banner (omitted when the
            // animated golden border is drawn on top).
            border: widget.animatedGoldenBorder
                ? null
                : Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                // Background image — network for real covers, asset for
                // bundled; wrapped in a subtle Ken Burns motion when enabled.
                _kenBurns(
                  Builder(
                  builder: (context) {
                    Widget fallback() => Container(
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
                        );
                    final url = event.imagePath;
                    if (url.startsWith('http')) {
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => fallback(),
                      );
                    }
                    return Image.asset(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => fallback(),
                    );
                  },
                ),
                ),

                // Cool animated FX — drifting sparkles + a glossy light sweep
                // (spotlight banner only).
                if (widget.animateImages)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          Positioned.fill(child: _BannerSparkles()),
                          Positioned.fill(child: _BannerShine()),
                        ],
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
                    top: 16,
                    right: 16,
                    child: WishlistButton(event: event),
                  ),
              ],
            ),
          ),
        );

    final bordered = widget.animatedGoldenBorder
        ? _AnimatedGoldenBorder(radius: radius, strokeWidth: 4, child: card)
        : card;

    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        ),
        child: bordered,
      ),
    );
  }
}

/// Wraps [child] with a ~4px golden gradient border that sweeps continuously
/// around the rounded card at a medium pace.
class _AnimatedGoldenBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;

  const _AnimatedGoldenBorder({
    required this.child,
    required this.radius,
    this.strokeWidth = 4,
  });

  @override
  State<_AnimatedGoldenBorder> createState() => _AnimatedGoldenBorderState();
}

class _AnimatedGoldenBorderState extends State<_AnimatedGoldenBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Medium pace: one full sweep around the border every 4 seconds.
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _GoldenBorderPainter(
            t: _controller.value,
            radius: widget.radius,
            strokeWidth: widget.strokeWidth,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _GoldenBorderPainter extends CustomPainter {
  final double t;
  final double radius;
  final double strokeWidth;

  _GoldenBorderPainter({
    required this.t,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius - inset),
    );

    // Golden sweep that rotates around the card — the bright "shine" stop
    // travels around the border as `t` advances.
    final gradient = SweepGradient(
      colors: const [
        Color(0xFFB8860B), // deep gold
        Color(0xFFFFC93C), // gold
        Color(0xFFFFF3B0), // light shine
        Color(0xFFFFC93C), // gold
        Color(0xFFB8860B), // deep gold (loops)
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(2 * math.pi * t),
    );

    final paint = Paint()
      ..shader = gradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GoldenBorderPainter old) =>
      old.t != t || old.radius != radius || old.strokeWidth != strokeWidth;
}

/// Wraps a banner image with a subtle, continuous Ken Burns effect — a slow
/// zoom paired with a drifting focal point — so the banner gently feels alive.
class _KenBurnsImage extends StatefulWidget {
  final Widget child;

  const _KenBurnsImage({required this.child});

  @override
  State<_KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<_KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<Alignment> _align;

  @override
  void initState() {
    super.initState();
    // Slow loop that eases back and forth, so the motion never snaps.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Noticeable zoom (1.0 → 1.18) with the focal point drifting diagonally.
    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(curve);
    _align = AlignmentTween(
      begin: const Alignment(-1.0, -0.7),
      end: const Alignment(1.0, 0.7),
    ).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          alignment: _align.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A glossy diagonal light band that slowly sweeps left → right across the
/// banner, then rests — adds a premium "shine" highlight.
class _BannerShine extends StatefulWidget {
  const _BannerShine();

  @override
  State<_BannerShine> createState() => _BannerShineState();
}

class _BannerShineState extends State<_BannerShine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep across the first half of the loop, then rest off-screen.
        final double p = Curves.easeInOut
            .transform((_controller.value / 0.5).clamp(0.0, 1.0));
        final double dx = -1.8 + 3.6 * p;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(dx - 0.4, -1.0),
              end: Alignment(dx + 0.4, 1.0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.18),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.4, 0.5, 0.6],
            ),
          ),
        );
      },
    );
  }
}

// Particle seeds for the banner sparkles: x(0-1), startY(0-1), radius, speed,
// phase. Fixed so the motion is deterministic (no Math.random at runtime).
const List<List<double>> _kSparkleSeeds = [
  [0.14, 0.85, 1.6, 0.70, 0.00],
  [0.32, 1.00, 1.1, 0.52, 0.30],
  [0.52, 0.78, 1.9, 0.88, 0.62],
  [0.68, 0.95, 1.3, 0.60, 0.12],
  [0.84, 0.82, 1.5, 0.80, 0.50],
  [0.24, 0.66, 1.0, 0.55, 0.82],
  [0.60, 0.90, 1.7, 0.74, 0.20],
  [0.44, 0.55, 1.2, 0.64, 0.92],
  [0.90, 0.70, 1.0, 0.58, 0.40],
  [0.08, 0.60, 1.3, 0.68, 0.74],
];

/// Soft white sparkles that drift upward and twinkle across the banner — a
/// subtle "dispersion" element that makes the banner feel alive.
class _BannerSparkles extends StatefulWidget {
  const _BannerSparkles();

  @override
  State<_BannerSparkles> createState() => _BannerSparklesState();
}

class _BannerSparklesState extends State<_BannerSparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          CustomPaint(painter: _SparklesPainter(_controller.value)),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double t;
  _SparklesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in _kSparkleSeeds) {
      final double x = s[0] * size.width;
      // Drift upward, looping; fade out as it rises.
      final double prog = (t * s[3] + s[4]) % 1.0;
      final double y = (s[1] - prog) * size.height;
      if (y < -6 || y > size.height + 6) continue;
      final double twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * 12.566 + s[4] * 6.283));
      final double op = (twinkle * (1.0 - prog) * 0.65).clamp(0.0, 1.0);
      // Soft glow halo.
      paint.color = Colors.white.withOpacity(op * 0.35);
      canvas.drawCircle(Offset(x, y), s[2] * 2.6, paint);
      // Bright core.
      paint.color = Colors.white.withOpacity(op);
      canvas.drawCircle(Offset(x, y), s[2], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) => old.t != t;
}
