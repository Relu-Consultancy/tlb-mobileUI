import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/event_model.dart';
import '../screens/event_detail_screen.dart';
import '../widgets/section_divider_widget.dart';

/// Theatrical "stage" Spotlight section.
///
/// Layer order (back → front): ambient cyan→pink glow, decorative leaves
/// header, floating stars, soft light beams, the stage platform (the card sits
/// ON it), the single focused spotlight card, the centered title, and the two
/// stage lights mounted at the top corners pointing down-inward. Data
/// integration is unchanged — it renders the same [EventModel] list.
class SpotlightStage extends StatefulWidget {
  final List<EventModel> events;

  const SpotlightStage({super.key, required this.events});

  static const String _leaves = 'resources- tlb-ui/spotlight/leaves.png';
  static const String _light = 'resources- tlb-ui/spotlight/lights.png';
  static const String _plate = 'resources- tlb-ui/spotlight/plate.png';
  static const String _star = 'resources- tlb-ui/spotlight/star.png';

  @override
  State<SpotlightStage> createState() => _SpotlightStageState();
}

class _SpotlightStageState extends State<SpotlightStage>
    with TickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final AnimationController _float;
  late final AnimationController _border; // running golden border + star
  late final AnimationController _curtain; // theatrical close/open transition
  late final AnimationController _sway; // lights pan left/right
  late final AnimationController _orbit; // plate star circular motion
  Timer? _auto;
  int _index = 0;

  /// Smooth −1..1 oscillation driving the light pan + beam sweep.
  double get _swayValue => math.sin(_sway.value * 2 * math.pi);

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _border = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000), // slow, graceful loop
    )..repeat();
    _sway = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200), // gentle left/right pan
    )..repeat();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500), // slow-medium circular orbit
    )..repeat();
    _curtain = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100), // slow, graceful roll
    )..addStatusListener((status) {
        // Fully closed → swap to the next card, then re-open the curtain.
        if (status == AnimationStatus.completed) {
          setState(() => _index = (_index + 1) % widget.events.length);
          _curtain.reverse();
        }
      });
    _startAuto();
  }

  void _startAuto() {
    _auto?.cancel();
    if (widget.events.length < 2) return;
    _auto = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      if (_curtain.status == AnimationStatus.dismissed) {
        _curtain.forward(from: 0); // close → swap → open
      }
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _shimmer.dispose();
    _float.dispose();
    _border.dispose();
    _curtain.dispose();
    _sway.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) return const SizedBox.shrink();

    final double screenW = MediaQuery.of(context).size.width;
    final double cardW = math.min(screenW - 44, 350);
    // Portrait banner art (~0.55 W/H) shown edge-to-edge → card takes that
    // aspect so the full design (logo + CTA) is never cropped.
    final double cardH = cardW * 1.8;

    // Taller top band so the stage lights sit fully ABOVE the card (they no
    // longer overlap its top corners).
    const double titleBand = 84;
    final double cardTop = titleBand;
    final double cardBottom = cardTop + cardH;

    // Stage platform — the card sits ON it. The new plate art is a wide, thin
    // ellipse (611×180) with a built-in left star + soft drop shadow and only
    // small transparent side margins, so it's drawn just slightly wider than the
    // card to make the visible ellipse span (and a touch overhang) the banner.
    final double plateW = cardW * 1.2;
    final double plateH = plateW * (180.0 / 611.0); // true art ratio
    // Tuck the plate up so its bright orange top rim (≈34% down the art) lands
    // right at the card's bottom edge → the banner appears to stand on it.
    final double plateTop = cardBottom - plateH * 0.34;
    // End the stage just past the plate's shadow, trimming the transparent tail.
    final double stageH = plateTop + plateH * 0.9;

    final double lightSize = cardW * 0.19;

    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: stageH,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 1 — Ambient glow.
                Positioned.fill(child: _glow()),

                // 2 — Leaves header (starts at the very top → no white gap).
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: titleBand + 46,
                  child: _leaves(),
                ),

                // 2.5 — Thin warm scrim ONLY at the very top seam: full header
                // cream at the join, gone within ~38px. This dissolves the hard
                // line where the header meets the stage WITHOUT washing out the
                // leaves (they stay fully visible just below).
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 38,
                  child: const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFBF3DE), // exact header cream at the seam
                            Color(0x00FBF3DE), // gone almost immediately
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3 — Floating stars.
                ..._stars(stageH, screenW),

                // 5 — Stage platform (drawn BEFORE the card → card sits on it).
                // The art's disc spans x=46..594 in a 611 canvas → its geometric
                // midpoint (320) sits ~2.4% right of the canvas centre, so nudge
                // the image left by that fraction to seat the disc centre exactly
                // under the (screen-centred) banner.
                Positioned(
                  top: plateTop,
                  left: (screenW - plateW) / 2 - plateW * 0.024,
                  width: plateW,
                  child: Image.asset(
                    SpotlightStage._plate,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

                // 5.5 — Continuously-shining star on the plate's LEFT corner
                // (sits over the star baked into the art, pulsing scale+glow).
                _plateStar(
                  plateLeft: (screenW - plateW) / 2 - plateW * 0.024,
                  plateW: plateW,
                  plateTop: plateTop,
                  plateH: plateH,
                ),

                // 6 — Single focused card with a theatrical curtain transition.
                Positioned(
                  top: cardTop,
                  left: 0,
                  right: 0,
                  height: cardH,
                  child: _SpotlightCard(
                    event: widget.events[_index],
                    width: cardW,
                    height: cardH,
                    shimmer: _shimmer,
                    border: _border,
                    curtain: _curtain,
                  ),
                ),

                // 6.2 — Twinkling star images flanking the banner (left + right).
                ..._sideStars(cardTop, cardH, screenW),

                // 6.5 — Volumetric light beams (yellow polygon cones) cast from
                // each light, drawn OVER the card so the light visibly falls on
                // the banner.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_shimmer, _sway]),
                      builder: (_, __) => CustomPaint(
                        painter: _BeamsPainter(
                          t: _shimmer.value,
                          lightSize: lightSize,
                          length: cardH * 0.78,
                          sway: _swayValue * 0.32, // beams track the lights
                        ),
                      ),
                    ),
                  ),
                ),

                // 7 — Centered title (over the leaves, between the lights).
                Positioned(
                  top: lightSize * 0.34,
                  left: 0,
                  right: 0,
                  child: const SectionDividerWidget(
                    title: 'Spotlight',
                    lineLength: 64,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: Color(0xFF3A3A3A),
                    lineThickness: 1.5,
                    lineColor: Color(0xFFD4A537),
                    topPadding: 0,
                    bottomPadding: 0,
                    showStars: true,
                  ),
                ),

                // 8 — Stage lights mounted to the LEFT/RIGHT screen edges (base
                // fixed at the side), heads angled down-inward toward the card.
                Positioned(
                  top: 10,
                  left: -lightSize * 0.24, // base stuck to the left edge
                  child: AnimatedBuilder(
                    animation: _sway,
                    builder: (_, __) =>
                        _light(lightSize, left: true, sway: _swayValue * 0.13),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: -lightSize * 0.24, // base stuck to the right edge
                  child: AnimatedBuilder(
                    animation: _sway,
                    builder: (_, __) =>
                        _light(lightSize, left: false, sway: _swayValue * 0.13),
                  ),
                ),
              ],
            ),
          ),

          if (widget.events.length > 1) ...[
            const SizedBox(height: 6), // dots closer to the plate
            AnimatedSmoothIndicator(
              activeIndex: _index,
              count: widget.events.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 7,
                dotWidth: 7,
                expansionFactor: 3,
                activeDotColor: Color(0xFFE8941A),
                dotColor: Color(0xFFE2D6C2),
                spacing: 5,
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _lightImage(double size) => Image.asset(
        SpotlightStage._light,
        width: size,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );

  /// Light oriented so its mounting base sits at the screen's side edge and the
  /// head points down-inward, with a [sway] pan added to the head. Source PNG:
  /// lens up-left, yoke at the bottom → flipX + 90° CW puts the yoke at the left
  /// edge; the right light is `rotate(-90°)` (the horizontal mirror).
  Widget _light(double size, {required bool left, required double sway}) {
    if (left) {
      return Transform.rotate(
        angle: math.pi / 2 + sway,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(-1, 1, 1), // flipX
          child: _lightImage(size),
        ),
      );
    }
    return Transform.rotate(
      angle: -math.pi / 2 + sway,
      child: _lightImage(size),
    );
  }

  // ── Plate corner star ────────────────────────────────────────────────────
  /// A vector sparkle attached at the plate's left corner that slowly travels
  /// in a small circle ([_orbit]) while twinkling brighter/dimmer ([_shimmer]),
  /// like a real star sparkle.
  Widget _plateStar({
    required double plateLeft,
    required double plateW,
    required double plateTop,
    required double plateH,
  }) {
    const double sparkBox = 42; // box holding one sparkle (+ its glow)
    const double orbitR = 9; // radius of the circular travel
    final double boxSize = sparkBox + orbitR * 2;
    // Anchor at the plate's left tip (~7.5% across, ~33% down the art).
    final double cx = plateLeft + plateW * 0.075;
    final double cy = plateTop + plateH * 0.33;
    return Positioned(
      left: cx - boxSize / 2,
      top: cy - boxSize / 2,
      width: boxSize,
      height: boxSize,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_orbit, _shimmer]),
          builder: (_, __) {
            final double ang = _orbit.value * 2 * math.pi; // round motion
            final Offset off =
                Offset(math.cos(ang) * orbitR, math.sin(ang) * orbitR);
            final double twinkle = 0.4 + 0.6 * _shimmer.value; // brightness
            return Center(
              child: Transform.translate(
                offset: off,
                child: SizedBox(
                  width: sparkBox,
                  height: sparkBox,
                  child: CustomPaint(painter: _StarPainter(twinkle)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Side stars ───────────────────────────────────────────────────────────
  /// Two star.png images sitting at the banner's left + right edges, gently
  /// twinkling (opacity + scale) in counter-phase so they sparkle alternately.
  List<Widget> _sideStars(double cardTop, double cardH, double screenW) {
    final double y = cardTop + cardH * 0.5; // vertically centred on the banner
    const double s = 50;

    Widget sideStar(double cx, bool invert) => Positioned(
          left: cx - s / 2,
          top: y - s / 2,
          width: s,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _shimmer,
              builder: (_, __) {
                final double p = invert ? 1 - _shimmer.value : _shimmer.value;
                return Opacity(
                  opacity: 0.6 + 0.4 * p,
                  child: Transform.scale(
                    scale: 0.85 + 0.22 * p,
                    child: Image.asset(
                      SpotlightStage._star,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ),
        );

    return [sideStar(26, false), sideStar(screenW - 26, true)];
  }

  // ── Ambient glow background ──────────────────────────────────────────────
  Widget _glow() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1 — Light diagonal multi-colour wash (softened pastel version so the
        //     darker banner card pops against it): pale teal → cyan → lilac →
        //     soft magenta → light pink.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8FE2DB), // pale teal
                Color(0xFF9AD3F0), // light cyan
                Color(0xFFBBAAEE), // lilac
                Color(0xFFDD9AC6), // soft magenta
                Color(0xFFF3AECB), // light pink
              ],
              stops: [0.0, 0.28, 0.52, 0.78, 1.0],
            ),
          ),
        ),
        // 2 — Radial glow blooms for depth (softer now that the wash is light).
        Positioned(
          top: -40,
          left: -60,
          child: _blob(const Color(0xFF9FF4E9), 260, 0.40),
        ),
        Positioned(
          bottom: 40,
          right: -60,
          child: _blob(const Color(0xFFFFB0D6), 280, 0.36),
        ),
        Positioned(
          top: 120,
          right: -40,
          child: _blob(const Color(0xFFC9A6FF), 220, 0.30),
        ),
        // 3 — Warm golden fade at the top → seamless blend with the golden
        //     header above the search bar. Held solid through the leaves + title
        //     band, then dissolved into the teal stage, so the foliage sits over
        //     warm gold (no green seam where it meets the header).
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFBF3DE), // exact header-bottom cream (seamless join)
                Color(0xFFFBF3DE), // hold solid behind the leaves/title
                Color(0x00FBF3DE), // dissolve into the teal stage below
              ],
              stops: [0.0, 0.18, 0.40],
            ),
          ),
        ),
        // 4 — White fade at the bottom → seamless blend into the white
        //     "Explore the Stage" section below.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), Color(0x00FFFFFF), Colors.white],
              stops: [0.0, 0.80, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  // ── Leaves header ────────────────────────────────────────────────────────
  // The foliage shows at full strength — ONLY its top edge is alpha-faded so it
  // melts into the golden header above. The rest of the image is left intact
  // (no warming/washing of the whole photo).
  Widget _leaves() {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent, // top dissolves into the gold header
          Colors.white,
          Colors.white,
          Colors.transparent, // bottom dissolves into the stage glow
        ],
        // Longer top fade-in so only the very top blends; the foliage stays
        // fully visible through the middle.
        stops: [0.0, 0.34, 0.74, 1.0],
      ).createShader(rect),
      child: Opacity(
        opacity: 0.92,
        child: Image.asset(
          SpotlightStage._leaves,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }


  // ── Floating stars ───────────────────────────────────────────────────────
  List<Widget> _stars(double stageH, double screenW) {
    final specs = <List<double>>[
      [0.05, 0.28, 22, 0.55, 0.0],
      [0.02, 0.50, 15, 0.40, 0.4],
      [0.09, 0.74, 18, 0.45, 0.8],
      [0.92, 0.32, 22, 0.55, 0.2],
      [0.95, 0.55, 15, 0.40, 0.6],
      [0.88, 0.80, 20, 0.50, 1.0],
    ];
    return specs.map((s) {
      return AnimatedBuilder(
        animation: _float,
        builder: (context, child) {
          final double t = math.sin((_float.value + s[4]) * math.pi * 2);
          return Positioned(
            left: screenW * s[0],
            top: stageH * s[1] + t * 4,
            child: Opacity(
              opacity: s[3],
              child: Image.asset(
                SpotlightStage._star,
                width: s[2],
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

/// The single focused spotlight card — a full-design portrait banner image
/// shown edge-to-edge, with the running golden border and the roller-curtain
/// transition kept on top.
class _SpotlightCard extends StatelessWidget {
  final EventModel event;
  final double width;
  final double height;
  final Animation<double> shimmer;
  final Animation<double> border;
  final Animation<double> curtain;

  const _SpotlightCard({
    required this.event,
    required this.width,
    required this.height,
    required this.shimmer,
    required this.border,
    required this.curtain,
  });

  static const double _radius = 30;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([shimmer, border, curtain]),
        builder: (context, child) {
          final double glow = 0.30 + shimmer.value * 0.20;
          // foregroundPainter draws the running border ON TOP of the card and
          // is sized EXACTLY to the card's box, so it always matches the banner.
          return CustomPaint(
            foregroundPainter:
                _RunningBorderPainter(t: border.value, radius: _radius),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB31C6C).withOpacity(glow),
                    blurRadius: 30,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0E8FA6).withOpacity(glow * 0.7),
                    blurRadius: 26,
                    spreadRadius: 1,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius - 1.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full banner artwork (its own logo + CTA), edge-to-edge.
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event)),
                      ),
                      child: Image.asset(
                        event.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFF2A1840),
                          child: Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.white54, size: 48),
                          ),
                        ),
                      ),
                    ),
                    // Theatrical curtain overlay. Eased for a smooth, fluid roll.
                    Positioned.fill(
                      child: _SpotlightCurtain(
                        value: Curves.easeInOutCubic.transform(curtain.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Draws a faint golden border around the card with two bright "comet"
/// highlights — on opposite corners — each led by an animated vector sparkle.
class _RunningBorderPainter extends CustomPainter {
  final double t; // 0..1 progress around the perimeter
  final double radius;

  _RunningBorderPainter({required this.t, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 5.0; // thicker running highlight
    final RRect rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(stroke / 2),
      Radius.circular(radius - stroke / 2),
    );
    final Path path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final ui.PathMetric metric = metrics.first;
    final double len = metric.length;

    // 1 — faint full golden border.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = const Color(0xFFFFE49B).withOpacity(0.32),
    );

    // 2 — two comets + star pointers, half a lap apart (opposite corners).
    _drawComet(canvas, metric, len, t, stroke);
    _drawComet(canvas, metric, len, (t + 0.5) % 1.0, stroke);
  }

  /// One comet trail ending in a star pointer at fractional position [frac].
  void _drawComet(Canvas canvas, ui.PathMetric metric, double len, double frac,
      double stroke) {
    final double head = (frac * len) % len;
    final double tailLen = len * 0.22;
    final double start = head - tailLen;
    final Path comet = Path();
    if (start < 0) {
      comet.addPath(metric.extractPath(len + start, len), Offset.zero);
      comet.addPath(metric.extractPath(0, head), Offset.zero);
    } else {
      comet.addPath(metric.extractPath(start, head), Offset.zero);
    }

    final ui.Tangent? headTan = metric.getTangentForOffset(head);
    final ui.Tangent? tailTan =
        metric.getTangentForOffset(start < 0 ? len + start : start);
    if (headTan == null || tailTan == null) return;

    canvas.drawPath(
      comet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          tailTan.position,
          headTan.position,
          const [Color(0x00FFD66B), Color(0xFFFFE9A8)],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );

    _drawSparkle(canvas, headTan.position);
  }

  void _drawSparkle(Canvas canvas, Offset c) {
    // Soft golden glow halo.
    canvas.drawCircle(
      c,
      8,
      Paint()
        ..color = const Color(0xFFFFECB3).withOpacity(0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // 4-point sparkle.
    const double outer = 7, inner = 2.2;
    final Path p = Path();
    for (int k = 0; k < 8; k++) {
      final double r = k.isEven ? outer : inner;
      final double a = (math.pi / 4) * k - math.pi / 2;
      final Offset pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      k == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = Colors.white);
    canvas.drawCircle(c, 2.2, Paint()..color = const Color(0xFFFFF6D8));
  }

  @override
  bool shouldRepaint(_RunningBorderPainter oldDelegate) => oldDelegate.t != t;
}

/// The SAME sparkle the running-border pointers use (white 4-point star + soft
/// golden glow halo + cream core), drawn centred in its box. [intensity] (0..1)
/// scales the rays + glow so it can twinkle/pulse. A touch larger than the
/// pointer as a focal corner accent.
class _StarPainter extends CustomPainter {
  final double intensity;

  _StarPainter(this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    // Pointer sparkle is outer≈7; here a hair larger and pulsing with intensity.
    final double outer = 9.0 * (0.7 + intensity * 0.5);
    final double inner = outer * 0.314; // same ratio as the pointer (2.2/7)

    // Soft golden glow halo (matches the pointer).
    canvas.drawCircle(
      c,
      outer * 1.14,
      Paint()
        ..color = const Color(0xFFFFECB3).withOpacity(0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, outer),
    );

    // White 4-point star.
    final Path p = Path();
    for (int k = 0; k < 8; k++) {
      final double r = k.isEven ? outer : inner;
      final double a = (math.pi / 4) * k - math.pi / 2;
      final Offset pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      k == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    canvas.drawPath(p, Paint()..color = Colors.white);

    // Cream core.
    canvas.drawCircle(c, inner, Paint()..color = const Color(0xFFFFF6D8));
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      oldDelegate.intensity != intensity;
}

/// Draws the two volumetric light beams as soft yellow polygon cones spreading
/// from each light's lens down onto the banner.
class _BeamsPainter extends CustomPainter {
  final double t; // shimmer 0..1 → gentle opacity pulse
  final double lightSize;
  final double length;
  final double sway; // horizontal sweep that tracks the panning lights

  _BeamsPainter({
    required this.t,
    required this.lightSize,
    required this.length,
    required this.sway,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double opacity = 0.5 + t * 0.22;
    _beam(canvas, size, left: true, opacity: opacity);
    _beam(canvas, size, left: false, opacity: opacity);
  }

  void _beam(Canvas canvas, Size size,
      {required bool left, required double opacity}) {
    // Lens (apex) just under each light fixture, near the inner edge.
    final double lensY = 10 + lightSize * 0.66;
    final double lensX =
        left ? lightSize * 0.58 : size.width - lightSize * 0.58;
    final Offset apex = Offset(lensX, lensY);

    // Axis points down + inward; cone widens toward the banner. `sway` sweeps
    // the beam horizontally in sync with the panning lights.
    final Offset dir = Offset((left ? 0.42 : -0.42) + sway, 1.0);
    final double dl = dir.distance;
    final Offset n = Offset(dir.dx / dl, dir.dy / dl);
    final Offset perp = Offset(-n.dy, n.dx);
    final Offset base = apex + n * length;

    const double apexHalf = 10;
    const double baseHalf = 62;
    Offset off(Offset p, Offset axisPerp, double w) =>
        Offset(p.dx + axisPerp.dx * w, p.dy + axisPerp.dy * w);

    final Path path = Path()
      ..moveTo(off(apex, perp, apexHalf).dx, off(apex, perp, apexHalf).dy)
      ..lineTo(off(apex, perp, -apexHalf).dx, off(apex, perp, -apexHalf).dy)
      ..lineTo(off(base, perp, -baseHalf).dx, off(base, perp, -baseHalf).dy)
      ..lineTo(off(base, perp, baseHalf).dx, off(base, perp, baseHalf).dy)
      ..close();

    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(
        apex,
        base,
        [
          const Color(0xFFFFF6BE).withOpacity(opacity), // bright at the lens
          const Color(0xFFFFEFA0).withOpacity(opacity * 0.45),
          const Color(0x00FFEFA0),
        ],
        const [0.0, 0.5, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BeamsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.sway != sway;
}

/// Theatrical red-velvet roller curtain that covers the banner. [value] 0 =
/// fully open (rolled up out of sight), 1 = fully closed (rolled all the way
/// down). The cloth hangs from a fixed top valance and its leading edge is a
/// curled, cylinder-like roll that travels DOWN to cover and UP to reveal —
/// reading like fabric rolling onto a pole.
class _SpotlightCurtain extends StatelessWidget {
  final double value;

  const _SpotlightCurtain({required this.value});

  /// Thickness of the curled roll at the leading edge.
  static const double _rollH = 30;

  // Vertical velvet pleats — alternating light/dark reds give the draped folds.
  static const List<Color> _pleats = [
    Color(0xFF5E0E0E),
    Color(0xFFC24040),
    Color(0xFF6E1414),
    Color(0xFFCE4A4A),
    Color(0xFF6E1414),
    Color(0xFFC24040),
    Color(0xFF5E0E0E),
    Color(0xFFC24040),
    Color(0xFF6E1414),
    Color(0xFFCE4A4A),
    Color(0xFF6E1414),
    Color(0xFFC24040),
    Color(0xFF5E0E0E),
  ];

  @override
  Widget build(BuildContext context) {
    if (value <= 0.001) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final double h = c.maxHeight;
        // Leading (bottom) edge of the descending cloth.
        final double edge = h * value;
        // How many times the roll has "turned" over the distance travelled — the
        // cylinder circumference (≈π·_rollH) divided into the travel. Drives the
        // scrolling surface highlights so the curl reads as physically rolling.
        final double rotations = h / (math.pi * _rollH);
        final double wrapPhase = value * rotations;
        // A gentle squash that breathes with each turn → a livelier, springier
        // curl rather than a rigid bar.
        final double squash = 1.0 - 0.06 * math.sin(wrapPhase * 2 * math.pi).abs();
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1 — Hanging cloth from the top valance down to just above the roll.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: math.max(0.0, edge - _rollH * 0.55),
              child: _cloth(),
            ),
            // 2 — Soft shadow the roll casts onto the banner just beneath it.
            Positioned(
              top: edge - 1,
              left: 0,
              right: 0,
              height: 16,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x55000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
            // 3 — The curled roll at the leading edge (the part that "rolls").
            Positioned(
              top: edge - _rollH,
              left: -2,
              right: -2,
              height: _rollH,
              child: Transform.scale(
                scaleY: squash,
                child: _roll(wrapPhase),
              ),
            ),
          ],
        );
      },
    );
  }

  /// The flat hanging velvet panel above the roll.
  Widget _cloth() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Pleated velvet folds.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _pleats,
            ),
          ),
        ),
        // Top-light sheen fading to a soft shadow near the roll.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.transparent,
                Colors.black.withOpacity(0.18),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
        // Gold valance trim fixed along the top.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 7,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE7B24A),
                  Color(0xFFF6D98A),
                  Color(0xFFC9942F),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The curled cylinder of fabric at the leading edge — shaded top→bottom like
  /// a lit horizontal roll, with the velvet pleats wrapping across it. The
  /// [wrapPhase] (total turns travelled) scrolls the surface highlights so the
  /// cylinder visibly spins as the curtain rolls up and down.
  Widget _roll(double wrapPhase) {
    // Two specular bands, half a turn apart, scrolling DOWN the cylinder face as
    // it rolls. `% 1` wraps them around; the ClipRRect hides the overshoot.
    final double f = wrapPhase % 1.0;
    final double band1 = f * _rollH;
    final double band2 = ((f + 0.5) % 1.0) * _rollH;
    Widget specBand(double y) => Positioned(
          top: y - 3,
          left: 6,
          right: 6,
          height: 6,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_rollH / 2),
        // Cylinder shading: dark rim, bright specular band, deep shadow rim.
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A0B0B), // dark top rim
            Color(0xFFB23636),
            Color(0xFFE86A6A), // bright specular highlight
            Color(0xFF9A2A2A),
            Color(0xFF360707), // deep bottom rim
          ],
          stops: [0.0, 0.24, 0.44, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_rollH / 2),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Velvet pleats wrapping across the roll (low opacity so the
            // cylinder shading still reads).
            Opacity(
              opacity: 0.35,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: _pleats,
                  ),
                ),
              ),
            ),
            // Scrolling specular bands → the cylinder appears to spin.
            specBand(band1),
            specBand(band2),
          ],
        ),
      ),
    );
  }
}
