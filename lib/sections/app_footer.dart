import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/footer_quote_carousel.dart';

/// The app-wide footer: a black "night sky" panel with a rotating quote, the
/// glowing TLB wordmark, a tagline and the policy links. Shown at the bottom of
/// the Home, Events, Classes, Programs and Venues screens.
class AppFooter extends StatelessWidget {
  /// Extra black height below the links so the footer reaches the screen bottom
  /// (covers the floating-navbar clearance, no gap).
  final double bottomExtra;

  const AppFooter({super.key, this.bottomExtra = 0});

  static const Color _gold = Color(0xFFE8B11E);
  static const Color _logoGold = Color(0xFFFFCE14);

  static const List<String> _links = [
    'Privacy Policy',
    'Terms & Conditions',
    'Contact Us',
    'Become a Partner',
  ];

  @override
  Widget build(BuildContext context) {
    final double logoWidth = MediaQuery.of(context).size.width * 0.44;

    return Container(
      width: double.infinity,
      // Fade from the (light) page into black over the first few percent so
      // there's no hard seam where the footer meets the section above.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black],
          stops: [0.0, 0.05, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Star field — sits below the top fade so no stars land on the page.
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: const _StarFieldPainter()),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 26),
              const FooterQuoteCarousel(),
              const SizedBox(height: 18),
              _buildLogo(context, logoWidth),
              const SizedBox(height: 22),
              _buildDivider(),
              const SizedBox(height: 18),
              Text(
                'Meaningful Experiences\nfor Kids & Families',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12.5),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.60),
                ),
              ),
              const SizedBox(height: 22),
              _buildLinks(context),
              SizedBox(height: 24 + bottomExtra),
            ],
          ),
        ],
      ),
    );
  }

  /// TLB wordmark with a soft radial gold glow behind it.
  Widget _buildLogo(BuildContext context, double logoWidth) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: logoWidth * 1.25,
          height: logoWidth * 0.7,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [_logoGold.withOpacity(0.22), Colors.transparent],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        SvgPicture.asset(
          'assets/icons/the_little_broadway_yellow.svg',
          width: logoWidth,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => SizedBox(height: logoWidth * 0.79),
        ),
      ],
    );
  }

  /// A gold line — diamond — gold line ornament, matching the reference.
  Widget _buildDivider() {
    Widget line({required bool fadeLeft}) => Container(
          width: 84,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: fadeLeft
                  ? [Colors.transparent, _gold]
                  : [_gold, Colors.transparent],
            ),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(fadeLeft: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(width: 7, height: 7, color: _gold),
          ),
        ),
        line(fadeLeft: false),
      ],
    );
  }

  /// Policy links separated by small gold dots, wrapping on narrow screens.
  Widget _buildLinks(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < _links.length; i++) {
      children.add(
        Text(
          _links[i],
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 11),
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      );
      if (i < _links.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle),
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8,
        children: children,
      ),
    );
  }
}

/// Paints a sparse field of gold "stars" biased toward the top. Deterministic
/// (fixed seed) so the stars hold still across rebuilds rather than twinkling.
class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter();

  static const Color _star = Color(0xFFFFCE14);
  static const int _count = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < _count; i++) {
      final x = rnd.nextDouble() * size.width;
      // pow(...) < 1 pushes the value toward 0, clustering stars near the top.
      final y = math.pow(rnd.nextDouble(), 1.8).toDouble() * size.height;
      final radius = 0.6 + rnd.nextDouble() * 1.6;
      final opacity = 0.25 + rnd.nextDouble() * 0.55;
      paint.color = _star.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => false;
}
