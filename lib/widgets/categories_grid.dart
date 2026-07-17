import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../screens/events_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/venues_screen.dart';

/// The "Explore the Stage" section: a "✦ Explore the Stage ✦" header and a row
/// of four dark, gold-bordered category cards (each a gold line-art glyph + a
/// label) on the black backdrop, sitting at the bottom of the Home hero.
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
      child: Stack(
        children: [
          // Soft golden radiance behind the card row.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, 0.2),
                    radius: 0.9,
                    colors: [Color(0x33FFB020), Color(0x00FFB020)],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitle(context),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (var i = 0; i < categories.length; i++) ...[
                      if (i > 0) const SizedBox(width: 11),
                      Expanded(child: _buildCard(context, categories[i])),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    Widget line() =>
        Container(width: 34, height: 1, color: const Color(0x66F5C042));
    Widget star() => const Icon(Icons.auto_awesome, size: 13, color: _gold);
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
            fontSize: Responsive.sp(context, 15),
            fontWeight: FontWeight.w600,
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
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1E0C), Color(0xFF150E06)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF7A5A22), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB800).withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              cat['icon'] as String,
              width: Responsive.w(context, 26),
              height: Responsive.w(context, 26),
              colorFilter: const ColorFilter.mode(_gold, BlendMode.srcIn),
              placeholderBuilder: (_) => const SizedBox(height: 26),
            ),
            SizedBox(height: Responsive.h(context, 9, min: 7)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 11.5),
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
