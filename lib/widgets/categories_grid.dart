import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import 'four_point_star.dart';
import '../screens/events_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/venues_screen.dart';

/// The "Explore the Stage" section: a "✦ Explore the Stage ✦" header and a row
/// of four dark cards — each a gold line-art glyph with sparkle accents, a
/// golden glow bar beneath it and a label — on the black backdrop.
class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  static const Color _gold = Color(0xFFF5C042);

  void _navigateTo(BuildContext context, String label) {
    Widget screen;
    switch (label) {
      case 'Events':
        screen = const EventsScreen();
        break;
      case 'Classes':
        screen = const ClassesScreen();
        break;
      case 'Programs':
        screen = const ProgramsScreen();
        break;
      case 'Venues':
        screen = const VenuesScreen();
        break;
      default:
        screen = const EventsScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final categories = DummyData.homeCategories;

    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 39),
        child: Transform.translate(
          // Nudge the whole section (title + cards) up 5px.
          offset: const Offset(0, -5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -10),
                child: _buildTitle(context),
              ),
              const SizedBox(height: 18),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Row(
                  children: [
                    for (var i = 0; i < categories.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(child: _buildCard(context, categories[i])),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    Widget line() =>
        Container(width: 34, height: 1, color: const Color(0x66F5C042));
    Widget star() => const FourPointStar(size: 14, color: _gold);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const SizedBox(width: 10),
        star(),
        const SizedBox(width: 9),
        Text(
          'Explore the Stage',
          style: GoogleFonts.poppins(
            fontSize: Responsive.sp(context, 17.5),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        star(),
        const SizedBox(width: 10),
        line(),
      ],
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> cat) {
    final label = cat['label'] as String;
    return GestureDetector(
      onTap: () => _navigateTo(context, label),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF201D19), // darker grey-brown card
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with small sparkle accents around it.
            SizedBox(
              width: 72,
              height: Responsive.h(context, 38, min: 34),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(top: 0, left: 2, child: _sparkle(12)),
                  Positioned(top: 6, right: 0, child: _sparkle(9)),
                  Image.asset(
                    cat['icon'] as String,
                    width: Responsive.w(context, 44),
                    height: Responsive.w(context, 44),
                    // Tint the black line-art PNG to gold.
                    color: _gold,
                    colorBlendMode: BlendMode.srcIn,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => const SizedBox(height: 44),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _glowBar(),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13.5),
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A small light-grey sparkle used as a decorative accent near the icon.
  Widget _sparkle(double size) => Icon(
        Icons.auto_awesome,
        size: size,
        color: Colors.white.withOpacity(0.45),
      );

  /// The golden glow bar sitting under each icon (the reference light streak).
  Widget _glowBar() => Container(
        width: 54,
        height: 3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: const LinearGradient(
            colors: [Colors.transparent, _gold, Colors.transparent],
          ),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.65),
              blurRadius: 9,
              spreadRadius: 0,
            ),
          ],
        ),
      );
}
