import 'dart:async';
import '../core/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
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

  /// When true, a ~4px gradient border sweeps continuously (medium pace)
  /// around each banner card. The border colour is a deep tone extracted from
  /// that banner's image, so it changes from card to card to match the art.
  final bool animatedAccentBorder;

  /// Fraction of the viewport each page occupies. Values below 1.0 reveal the
  /// previous/next banners peeking at the left and right edges (carousel
  /// look). When set, the card width is derived from the page width and
  /// [fixedCardWidth] is ignored.
  final double? viewportFraction;

  /// When true, each banner image gently floats — a slow drifting + parallax
  /// sway (no zoom) so the elements inside the image feel like they move.
  final bool animateImages;

  /// When true, the carousel scrolls endlessly — after the last card it keeps
  /// advancing forward into the first (no rewind back to the start).
  final bool infiniteScroll;

  /// When true, a soft gradient backdrop is painted behind the banner; its
  /// colour is sampled from the current banner image and lerps smoothly to the
  /// neighbouring banner's colour as the carousel scrolls.
  final bool tintedBackground;

  /// Master switch for the "spotlight focus" treatment: dim + desaturated side
  /// cards, a deeper centre-card shadow, a colour-matched glow behind the
  /// active card, a one-time swipe nudge, an idle breathing pulse,
  /// touch-paused auto-advance, and a larger accent page indicator. Everything
  /// is gated by this single flag, so it can be reverted in one line.
  final bool spotlightEnhancements;

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
    this.animatedAccentBorder = false,
    this.viewportFraction,
    this.animateImages = false,
    this.infiniteScroll = false,
    this.tintedBackground = false,
    this.spotlightEnhancements = false,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with TickerProviderStateMixin {
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

  // Soft backdrop band colour per banner index (sampled from the image).
  final Map<int, Color> _bandColors = {};
  // Neutral fallback band used until the colours have been sampled.
  static const Color _defaultBand = Color(0xFFC9B6EE);

  // ── Spotlight-enhancement extras (gated by spotlightEnhancements) ──────────
  AnimationController? _breatheController; // idle "breathing" pulse
  // The first-view swipe nudge plays only once per app session.
  static bool _nudgeShownThisSession = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.infiniteScroll ? _loopBase : 0;
    _pageController = PageController(
      viewportFraction: widget.viewportFraction ?? 1.0,
      initialPage: _currentIndex,
    );
    _startAutoSlide();
    if (widget.tintedBackground || widget.spotlightEnhancements) {
      _loadBandColors();
    }
    if (widget.spotlightEnhancements) {
      _breatheController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
      )..repeat(reverse: true);
      if (!_nudgeShownThisSession) {
        _nudgeShownThisSession = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _playNudge());
      }
    }
  }

  /// Listenable driving the peek transform — merges the page controller with
  /// the breathing controller (when enhancements are on) so the centre card
  /// can pulse subtly while idle.
  Listenable get _peekAnim => _breatheController != null
      ? Listenable.merge([_pageController, _breatheController!])
      : _pageController;

  /// One-time, gentle "this is swipeable" nudge: the carousel eases a little to
  /// the right then settles back, hinting the user can swipe for more.
  Future<void> _playNudge() async {
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted || _userInteracting || !_pageController.hasClients) return;
    final pos = _pageController.position;
    if (!pos.haveDimensions) return;
    final base = pos.pixels;
    try {
      await _pageController.animateTo(base + 34,
          duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
      if (!mounted || _userInteracting) return;
      await _pageController.animateTo(base,
          duration: const Duration(milliseconds: 540),
          curve: Curves.easeOutBack);
    } catch (_) {
      // Ignore — controller detached mid-nudge.
    }
  }

  /// A deeper, more saturated version of the current backdrop accent — used for
  /// the glow halo and the active page dot.
  Color _accentDeep() {
    final hsl = HSLColor.fromColor(_currentBandColor());
    return hsl
        .withSaturation((hsl.saturation + 0.18).clamp(0.4, 1.0))
        .withLightness(0.52)
        .toColor();
  }

  /// Combined desaturate + dim colour filter for the peeking side cards — one
  /// `saveLayer` instead of stacking Opacity + ColorFiltered.
  ColorFilter _dimDesat(double sat, double opacity) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final inv = 1 - sat;
    return ColorFilter.matrix(<double>[
      lr * inv + sat, lg * inv, lb * inv, 0, 0, //
      lr * inv, lg * inv + sat, lb * inv, 0, 0, //
      lr * inv, lg * inv, lb * inv + sat, 0, 0, //
      0, 0, 0, opacity, 0, //
    ]);
  }

  /// Larger page dots with an accent-coloured active dot + an "n / total"
  /// counter (used only for the spotlight's external indicator row).
  Widget _buildEnhancedIndicator(BuildContext context) {
    final active = widget.infiniteScroll
        ? _currentIndex % widget.events.length
        : _currentIndex;
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSmoothIndicator(
              activeIndex: active,
              count: widget.events.length,
              effect: WormEffect(
                dotHeight: 9,
                dotWidth: 9,
                activeDotColor: _accentDeep(),
                dotColor: const Color(0xFFD9D9D9),
                spacing: 7,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${active + 1} / ${widget.events.length}',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  // Sample each banner's colour once and convert it into a soft (but slightly
  // deep) backdrop tint that matches the artwork.
  Future<void> _loadBandColors() async {
    for (var i = 0; i < widget.events.length; i++) {
      final raw = await _BannerAccent.of(widget.events[i].imagePath);
      if (!mounted) return;
      if (raw != null) {
        final hsl = HSLColor.fromColor(raw);
        final band = hsl
            .withSaturation((hsl.saturation * 0.82).clamp(0.28, 0.72))
            .withLightness(0.72) // a touch darker than the old flat violet
            .toColor();
        setState(() => _bandColors[i] = band);
      }
    }
  }

  // Backdrop band colour for the current scroll position — interpolated
  // between the two banners on screen so the tint changes smoothly.
  Color _currentBandColor() {
    if (widget.events.isEmpty) return _defaultBand;
    double page = _currentIndex.toDouble();
    if (_pageController.hasClients &&
        _pageController.position.haveDimensions) {
      page = _pageController.page ?? page;
    }
    final lo = page.floor();
    final f = page - lo;
    Color bandFor(int virtual) =>
        _bandColors[virtual % widget.events.length] ?? _defaultBand;
    return Color.lerp(bandFor(lo), bandFor(lo + 1), f) ?? bandFor(lo);
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _breatheController?.dispose();
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

    final indicator = (widget.spotlightEnhancements && !widget.overlayDots)
        ? _buildEnhancedIndicator(context)
        : AnimatedSmoothIndicator(
            activeIndex: widget.infiniteScroll
                ? _currentIndex % widget.events.length
                : _currentIndex,
            count: widget.events.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor:
                  widget.overlayDots ? Colors.white : AppColors.starAmber,
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

    final content = Column(
      children: [
        // ── Swipeable PageView ────────────────────────────────────────
        SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Soft colour-matched glow halo behind the active card.
              if (widget.spotlightEnhancements)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, _) {
                        final glow = _accentDeep();
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, -0.05),
                              radius: 0.62,
                              colors: [
                                glow.withOpacity(0.40),
                                glow.withOpacity(0.0),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollStartNotification) {
                    _userInteracting = true;
                    // Pause auto-advance the moment the user touches it so the
                    // timer never fights the gesture.
                    if (widget.spotlightEnhancements) _autoSlideTimer?.cancel();
                  } else if (n is ScrollEndNotification) {
                    _userInteracting = false;
                    // Resume after a full fresh interval once they let go.
                    if (widget.spotlightEnhancements) _startAutoSlide();
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
                        animation: _peekAnim,
                        builder: (context, child) {
                          double rel = 0.0; // <0 = left side, >0 = right side
                          if (_pageController.position.haveDimensions) {
                            final page = _pageController.page ??
                                _currentIndex.toDouble();
                            rel = (i - page).clamp(-1.0, 1.0);
                          }
                          final diff = rel.abs();
                          final enh = widget.spotlightEnhancements;
                          // Centre card = 1.0; neighbours ~0.84 normally, ~0.80
                          // (bigger contrast) when enhanced.
                          double scale = 1.0 - diff * (enh ? 0.20 : 0.16);
                          if (enh && _breatheController != null) {
                            // Subtle idle breathing pulse, strongest on the
                            // centred card, paused while the user is swiping.
                            final centered = (1.0 - diff).clamp(0.0, 1.0);
                            final pulse = _userInteracting
                                ? 0.0
                                : Curves.easeInOut
                                    .transform(_breatheController!.value);
                            scale *= 1.0 + centered * 0.012 * pulse;
                          }
                          // Right neighbour anchors on its left edge, left
                          // neighbour on its right edge — keeps the peek width.
                          final alignment = rel >= 0
                              ? Alignment.centerLeft
                              : Alignment.centerRight;
                          Widget c = child!;
                          if (enh && diff > 0.001) {
                            // Dim + desaturate side cards so the centre pops.
                            final sat = (1.0 - diff * 0.6).clamp(0.0, 1.0);
                            final op = (1.0 - diff * 0.45).clamp(0.0, 1.0);
                            c = ColorFiltered(
                              colorFilter: _dimDesat(sat, op),
                              child: c,
                            );
                          }
                          return Transform.scale(
                            scale: scale,
                            alignment: alignment,
                            child: c,
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
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 6),
          ] else
            const SizedBox(height: 12),
          indicator,
        ],
      ],
    );

    if (!widget.tintedBackground) return content;

    // Soft backdrop tint that tracks (and lerps between) the banner colours.
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final band = _currentBandColor();
        final outer =
            HSLColor.fromColor(band).withLightness(0.84).toColor();
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, outer, band, outer, Colors.white],
              stops: const [0.0, 0.22, 0.5, 0.78, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: content,
    );
  }

  /// Wraps [child] in a gentle floating/parallax drift when [animateImages]
  /// is set (no zoom — the scene sways as if the elements inside are moving).
  Widget _floating(Widget child) =>
      widget.animateImages ? _FloatingImage(child: child) : child;

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
            // animated accent border is drawn on top).
            border: widget.animatedAccentBorder
                ? null
                : Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
            // Deeper, softer drop shadow that lifts the card off the backdrop
            // (side cards inherit it but are dimmed, so only the centre pops).
            boxShadow: widget.spotlightEnhancements
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 30,
                      spreadRadius: -6,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.hardEdge,
              children: [
                // Background image — network for real covers, asset for
                // bundled; wrapped in a subtle Ken Burns motion when enabled.
                _floating(
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
                          color: AppColors.primaryLight,
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
                                  color: AppColors.textPrimary,
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

    final bordered = widget.animatedAccentBorder
        ? _AnimatedAccentBorder(
            radius: radius,
            strokeWidth: 4,
            imagePath: event.imagePath,
            child: card,
          )
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

/// Resolves and caches a deep accent colour for each banner image. The colour
/// is sampled from the image itself (via [PaletteGenerator]) so the moving
/// border around the banner matches the artwork and changes per card.
class _BannerAccent {
  _BannerAccent._();

  static final Map<String, Color> _cache = {};
  static final Map<String, Future<Color?>> _inflight = {};

  /// Golden tone used until the real colour has been extracted.
  static const Color fallback = Color(0xFFB8860B);

  static Future<Color?> of(String imagePath) {
    if (_cache.containsKey(imagePath)) return Future.value(_cache[imagePath]);
    return _inflight.putIfAbsent(imagePath, () async {
      final color = await _extract(imagePath);
      if (color != null) _cache[imagePath] = color;
      _inflight.remove(imagePath);
      return color;
    });
  }

  static Future<Color?> _extract(String imagePath) async {
    try {
      final ImageProvider provider = imagePath.startsWith('http')
          ? NetworkImage(imagePath)
          : AssetImage(imagePath) as ImageProvider;
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        size: const Size(140, 90),
        maximumColorCount: 16,
      );
      final swatch = palette.darkVibrantColor ??
          palette.vibrantColor ??
          palette.dominantColor ??
          palette.darkMutedColor ??
          palette.mutedColor;
      if (swatch == null) return null;
      // Push toward a rich, deep, saturated tone for a bold border.
      final hsl = HSLColor.fromColor(swatch.color);
      return hsl
          .withSaturation((hsl.saturation + 0.25).clamp(0.5, 1.0))
          .withLightness(hsl.lightness.clamp(0.30, 0.48))
          .toColor();
    } catch (_) {
      return null;
    }
  }
}

/// Wraps [child] with a ~4px gradient border that sweeps continuously around
/// the rounded card. The colour is a deep tone sampled from [imagePath] so the
/// border dynamically matches each banner image.
class _AnimatedAccentBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;
  final String imagePath;

  const _AnimatedAccentBorder({
    required this.child,
    required this.radius,
    required this.imagePath,
    this.strokeWidth = 4,
  });

  @override
  State<_AnimatedAccentBorder> createState() => _AnimatedAccentBorderState();
}

class _AnimatedAccentBorderState extends State<_AnimatedAccentBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Color _accent = _BannerAccent.fallback;

  @override
  void initState() {
    super.initState();
    // Medium pace: one full sweep around the border every 4 seconds.
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _resolveAccent();
  }

  @override
  void didUpdateWidget(covariant _AnimatedAccentBorder old) {
    super.didUpdateWidget(old);
    if (old.imagePath != widget.imagePath) _resolveAccent();
  }

  Future<void> _resolveAccent() async {
    final color = await _BannerAccent.of(widget.imagePath);
    if (mounted && color != null && color != _accent) {
      setState(() => _accent = color);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Settle smoothly into the resolved colour (and crossfade when the card's
    // image — and therefore its accent — changes).
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 700),
      tween: ColorTween(begin: _BannerAccent.fallback, end: _accent),
      builder: (context, color, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, inner) {
            return CustomPaint(
              foregroundPainter: _AccentBorderPainter(
                t: _controller.value,
                radius: widget.radius,
                strokeWidth: widget.strokeWidth,
                base: color ?? _accent,
              ),
              child: inner,
            );
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _AccentBorderPainter extends CustomPainter {
  final double t;
  final double radius;
  final double strokeWidth;
  final Color base;

  _AccentBorderPainter({
    required this.t,
    required this.radius,
    required this.strokeWidth,
    required this.base,
  });

  Color _shiftLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0))
        .toColor();
  }

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

    // Deep accent sweep — a bright shine stop travels around the border as `t`
    // advances. Built from the banner's own sampled colour.
    final deep = _shiftLightness(base, -0.14);
    final shine = _shiftLightness(base, 0.26);
    final gradient = SweepGradient(
      colors: [deep, base, shine, base, deep],
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
  bool shouldRepaint(covariant _AccentBorderPainter old) =>
      old.t != t ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.base != base;
}

/// Wraps a banner image with a gentle floating/parallax motion — the scene
/// continuously drifts and sways with a slight 3D tilt (NO zoom pulsing), so
/// the elements inside the image feel like they're subtly moving.
class _FloatingImage extends StatefulWidget {
  final Widget child;

  const _FloatingImage({required this.child});

  @override
  State<_FloatingImage> createState() => _FloatingImageState();
}

class _FloatingImageState extends State<_FloatingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slow, seamless loop (no reverse) — the drift follows a Lissajous path so
    // it never snaps back at the loop boundary.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
      builder: (context, child) {
        final a = _controller.value * 2 * math.pi;
        // Drifting pan (figure-eight) + a tiny perspective sway. The constant
        // 1.14 over-scale is fixed headroom (not an animated zoom) so the drift
        // and tilt never expose the card edges.
        final dx = math.sin(a) * 11.0;
        final dy = math.sin(a * 2) * 7.0;
        final tilt = Matrix4.identity()
          ..setEntry(3, 2, 0.0009)
          ..rotateY(math.sin(a) * 0.045)
          ..rotateX(math.sin(a * 2) * 0.025);
        return Transform(
          alignment: Alignment.center,
          transform: tilt,
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(scale: 1.14, child: child),
          ),
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
