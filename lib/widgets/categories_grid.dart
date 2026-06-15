import 'package:flutter/material.dart';
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

    return Column(
      children: [
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
                    color: const Color(0xFF1A1A2E),
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

        const SizedBox(height: 12),
      ],
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
    // StackFit.expand forces the Container to fill the grid cell tightly,
    // so no fixed width/height is needed — the cell dimensions drive sizing.
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFCE7A6), // light golden tint at the top
                Color(0xFFFEF3D2), // very light gold through the middle
                Colors.white, // reaches pure white...
                Colors.white, // ...and holds it so the bottom blends seamlessly
              ],
              stops: [0.0, 0.42, 0.78, 1.0],
            ),
            borderRadius: BorderRadius.circular(cardRadius),
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
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  cat['subtitle'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 11),
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3-sided border — left, top, right only; bottom open so gradient blends into page.
        Positioned.fill(
          child: CustomPaint(
            painter: _ThreeSidedBorderPainter(
              color: const Color(0xFFCE9B1E),
              radius: cardRadius,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a rounded-rectangle border on left, top, and right sides only.
class _ThreeSidedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _ThreeSidedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt
      // Golden at the top, fading to transparent toward the bottom so the
      // side borders dissolve into the page (matches the fill's fade-out).
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0.0)],
        stops: const [0.35, 0.78],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final r = radius;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r), clockwise: true)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r), clockwise: true)
      ..lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ThreeSidedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
