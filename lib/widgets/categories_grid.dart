import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../screens/events_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/venues_screen.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

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
    const double hPadding = 16;
    const double hSpacing = 14;
    const double vSpacing = 14;

    return Container(
      // Black backdrop for the "Explore the Stage" section. Soft white fades
      // at the top and bottom let it meet the SpotlightStage's white lower
      // edge above and the white section below without a hard seam.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.black, Colors.black, Colors.white],
          stops: [0.0, 0.07, 0.93, 1.0],
        ),
      ),
      child: Column(
      children: [
        const SizedBox(height: 6),
        // ── "Explore the Stage" title with gradient lines ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPadding, vertical: 20),
          child: Row(
            children: [
              Expanded(child: _buildLine(isLeft: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Explore the Stage',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 17),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(child: _buildLine(isLeft: false)),
            ],
          ),
        ),

        // ── 2×2 card grid — LayoutBuilder computes exact cell aspect ratio ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = (constraints.maxWidth - hSpacing) / 2;
              final cardHeight = Responsive.h(context, 178, min: 158);
              final aspectRatio = cellWidth / cardHeight;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: hSpacing,
                  mainAxisSpacing: vSpacing,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () => _navigateTo(context, cat['label']),
                    child: _buildCategoryCard(context, cat),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 22),
      ],
      ),
    );
  }

  Widget _buildLine({required bool isLeft}) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLeft
              ? [Colors.transparent, const Color(0xFFCFAD6A)]
              : [const Color(0xFFCFAD6A), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> cat) {
    const double cardRadius = 20;
    const Color goldBorder = Color(0xFFCE9B1E);
    // Self-contained golden card that glows on the black backdrop: a full
    // rounded gold border on all four sides plus a soft gold shadow, so each
    // card reads as a lit tile rather than dissolving into a white page.
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCE7A6), // light golden tint at the top
            Color(0xFFFEF3D2), // very light gold through the middle
            Colors.white, // settles to white toward the bottom
            Colors.white,
          ],
          stops: [0.0, 0.42, 0.78, 1.0],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: goldBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: goldBorder.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
              child: Image.asset(
                cat['image'],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.category_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Text(
            cat['label'],
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 14),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              cat['subtitle'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 11),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF5C5C5C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
