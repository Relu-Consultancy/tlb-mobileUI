import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../screens/events_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/venues_screen.dart';

/// The "Explore the Stage" section: a single row of gold line-art category
/// glyphs with labels, split by thin vertical dividers, on the black backdrop
/// that runs down from the Spotlight banner above.
class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  static const Color _gold = Color(0xFFF5C042);
  static const Color _divider = Color(0x26FFFFFF); // white @ 15%

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

    return Container(
      // Black backdrop. Black continues straight down from the Spotlight banner
      // above; only the bottom fades out to white so it meets the light section
      // below without a hard seam.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black, Colors.white],
          stops: [0.0, 0.88, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Soft golden radiance behind the icon row (fades to transparent so
          // the black base and the bottom white fade are preserved).
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.35),
                    radius: 0.9,
                    colors: [Color(0x33FFB020), Color(0x00FFB020)],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 26, 8, 34),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < categories.length; i++) ...[
                    if (i > 0)
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: _divider,
                        indent: 6,
                        endIndent: 6,
                      ),
                    Expanded(child: _buildItem(context, categories[i])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> cat) {
    final label = cat['label'] as String;
    return InkWell(
      onTap: () => _navigateTo(context, label),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              cat['icon'] as String,
              width: Responsive.w(context, 30),
              height: Responsive.w(context, 30),
              colorFilter: const ColorFilter.mode(_gold, BlendMode.srcIn),
              placeholderBuilder: (_) => const SizedBox(height: 30),
            ),
            SizedBox(height: Responsive.h(context, 12, min: 9)),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 13),
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
