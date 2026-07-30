import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import 'four_point_star.dart';

/// Shared building blocks for the black "night theatre" category region used at
/// the top of the Events, Classes and Programs screens: the centered gold
/// ornament title, the translucent "View All" pill, and the banner side-glow.
const Color kDarkSectionGold = Color(0xFFF5C042);

/// Golden light spilling out a banner's left & right edges (same side-glow look
/// as the Home Spotlight card). Sides only — no top/bottom shadow.
///
/// Apply to a rounded box placed BEHIND the banner that ALSO has an opaque fill
/// (e.g. black) — the fill backs the image so the glow can't bleed through the
/// banner's transparent areas; only the edge spill shows.
List<BoxShadow> goldBannerSideGlow({double opacity = 0.40}) => [
      BoxShadow(
        color: kDarkSectionGold.withOpacity(opacity),
        blurRadius: 30,
        spreadRadius: -8,
        offset: const Offset(-13, 0),
      ),
      BoxShadow(
        color: kDarkSectionGold.withOpacity(opacity),
        blurRadius: 30,
        spreadRadius: -8,
        offset: const Offset(13, 0),
      ),
    ];

/// "─ ✦ {title} ✦ ─" — the centered gold ornament title (single 4-point stars),
/// matching the Home section titles, on the black region.
class DarkCategoryTitle extends StatelessWidget {
  final String title;

  const DarkCategoryTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Container(width: 30, height: 1, color: const Color(0x66F5C042));
    Widget star() => const FourPointStar(size: 14, color: kDarkSectionGold);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        line(),
        const SizedBox(width: 10),
        star(),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 17),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 9),
        star(),
        const SizedBox(width: 10),
        line(),
      ],
    );
  }
}

/// The "View All →" pill — dark translucent so it blends over the bright bottom
/// cards when floated on top of the category grid.
class DarkViewAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const DarkViewAllButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF4D4D4D), // medium grey
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
