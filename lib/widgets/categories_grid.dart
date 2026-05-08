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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5A5A5A),
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
                    child: _buildCategoryCard(cat),
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

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
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
                Color(0xFFF0E6D0),
                Color(0xFFF0E6D0),
                Colors.white,
              ],
              stops: [0.0, 0.58, 1.0],
            ),
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(-4, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                spreadRadius: -4,
                offset: const Offset(4, 0),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: -3,
                offset: const Offset(0, -2),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  cat['subtitle'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
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
              color: const Color(0xFFD8C9A8),
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
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt;

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
