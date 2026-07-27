import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/footer_quote_carousel.dart';

/// The app-wide footer: a black "night sky" panel with a rotating italic quote,
/// the glowing TLB wordmark, a DISCOVER · CONNECT · CREATE line, a tagline, a
/// policy-link grid and social icons. Shown at the bottom of the Home, Events,
/// Classes, Programs and Venues screens.
class AppFooter extends StatelessWidget {
  /// Extra black height below the content so the footer reaches the screen
  /// bottom (covers the floating-navbar clearance, no gap).
  final double bottomExtra;

  const AppFooter({super.key, this.bottomExtra = 0});

  static const Color _gold = Color(0xFFE8B11E);
  static const Color _logoGold = Color(0xFFFFCE14);

  @override
  Widget build(BuildContext context) {
    final double logoWidth = MediaQuery.of(context).size.width * 0.46;

    // Height of the top fade zone: the page above melts into black over this
    // many px before any footer content begins. Fixed px (not a % of the tall
    // footer) keeps the fade long and gradual regardless of content height.
    const double fadeHeight = 130;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Solid black fill for everything below the fade zone.
          const Positioned(
            top: fadeHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: ColoredBox(color: Colors.black),
          ),
          // The fade itself: transparent at the very top (so the light section
          // above shows through) easing down into black — no hard seam.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: fadeHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Star field — sits below the fade so no stars land on the page.
          const Positioned(
            top: fadeHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(painter: _StarFieldPainter()),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear the fade zone so the quote sits on solid black.
              const SizedBox(height: fadeHeight + 8),
              const FooterQuoteCarousel(),
              const SizedBox(height: 20),
              _buildLogo(context, logoWidth),
              const SizedBox(height: 22),
              _buildBrandLine(context),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 18),
              Text(
                'Curating meaningful experiences\nfor kids & families.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 12.5),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.60),
                ),
              ),
              const SizedBox(height: 24),
              _thinDivider(),
              const SizedBox(height: 20),
              _buildLinksGrid(context),
              const SizedBox(height: 26),
              _buildSocialRow(context),
              SizedBox(height: 26 + bottomExtra),
            ],
          ),
        ],
      ),
    );
  }

  /// TLB wordmark with a soft radial gold glow behind it and a horizontal
  /// golden glow bar beneath (the reference's light streak).
  Widget _buildLogo(BuildContext context, double logoWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
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
        ),
        const SizedBox(height: 8),
        // Golden glow bar / light streak under the logo.
        Container(
          width: logoWidth * 0.72,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Colors.transparent, _logoGold, Colors.transparent],
            ),
            boxShadow: [
              BoxShadow(
                color: _logoGold.withOpacity(0.55),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// DISCOVER · CONNECT · CREATE — gold, spaced, with bullet separators.
  Widget _buildBrandLine(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: Responsive.sp(context, 12.5),
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: _gold,
    );
    Widget word(String w) => Text(w, style: style);
    Widget dot() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('•', style: style),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [word('DISCOVER'), dot(), word('CONNECT'), dot(), word('CREATE')],
    );
  }

  /// A gold line — sparkle — gold line ornament.
  Widget _buildDivider() {
    Widget line({required bool fadeLeft}) => Container(
          width: 78,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.auto_awesome, size: 14, color: _gold),
        ),
        line(fadeLeft: false),
      ],
    );
  }

  Widget _thinDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      height: 1,
      color: Colors.white.withOpacity(0.08),
    );
  }

  /// Policy links in a 2×2 grid with a vertical divider between the columns.
  Widget _buildLinksGrid(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: Responsive.sp(context, 12.5),
      fontWeight: FontWeight.w400,
      color: Colors.white.withOpacity(0.75),
    );
    Widget link(String label) => Text(label, style: style);
    Widget column(String a, String b) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [link(a), const SizedBox(height: 18), link(b)],
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Center(child: column('Privacy Policy', 'Terms & Conditions'))),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.white.withOpacity(0.10),
              indent: 2,
              endIndent: 2,
            ),
            Expanded(child: Center(child: column('Contact Us', 'Become a Partner'))),
          ],
        ),
      ),
    );
  }

  /// Instagram · WhatsApp · LinkedIn in circular outlined buttons.
  Widget _buildSocialRow(BuildContext context) {
    Widget btn(String asset) => Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _gold.withOpacity(0.55), width: 1.2),
          ),
          child: Center(
            child: SvgPicture.asset(asset, width: 20, height: 20),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        btn('assets/icons/social_instagram.svg'),
        const SizedBox(width: 20),
        btn('assets/icons/social_whatsapp.svg'),
        const SizedBox(width: 20),
        btn('assets/icons/social_linkedin.svg'),
      ],
    );
  }
}

/// Paints a sparse field of gold "stars" biased toward the top. Deterministic
/// (fixed seed) so the stars hold still across rebuilds rather than twinkling.
class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter();

  static const Color _star = Color(0xFFFFCE14);
  static const int _count = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < _count; i++) {
      final x = rnd.nextDouble() * size.width;
      // pow(...) < 1 pushes the value toward 0, clustering stars near the top.
      final y = math.pow(rnd.nextDouble(), 1.8).toDouble() * size.height;
      final radius = 0.5 + rnd.nextDouble() * 1.1;
      final opacity = 0.15 + rnd.nextDouble() * 0.35;
      paint.color = _star.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter oldDelegate) => false;
}
