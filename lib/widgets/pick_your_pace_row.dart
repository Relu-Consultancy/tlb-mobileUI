import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class PickYourPaceRow extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const PickYourPaceRow({
    super.key,
    required this.items,
  });

  static const double _sidePadding = 16;
  static const double _gap = 14;
  static const int _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Subtract only the leading padding so exactly [_visibleCount] circles
        // span from the left edge to the right edge — each disc is larger and
        // no 4th disc peeks in.
        final double available = constraints.maxWidth - _sidePadding;
        final double circleSize =
            (available - (_visibleCount - 1) * _gap) / _visibleCount;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> item = entry.value;
              final bool isLast = index == items.length - 1;
              // Soft pastel base behind the icon (matches the reference).
              final List<Color> bg = (item['bg'] as List?)?.cast<Color>() ??
                  const [Colors.white, Colors.white];

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : _gap),
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Light pastel fill instead of plain white.
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: bg,
                    ),
                    // Very thin, light black boundary around the circle.
                    border: Border.all(
                      color: Colors.black.withOpacity(0.18),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  // The assets are already finished circular icons (each with its
                  // own coloured circle baked in). We fill the circle with the
                  // image and overlay the title INSIDE the circle at the bottom —
                  // no dark scrim, the light circle shows through and the label is
                  // black with a soft white halo so it stays readable.
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.class_, color: Colors.grey),
                        ),
                        // Soft gradient veil to give the disc the reference
                        // gradient tint. The icon images have opaque
                        // backgrounds, so this washes the card's bottom tone
                        // over the lower half while keeping the top (and the
                        // icon) clear.
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  bg.first.withOpacity(0.0),
                                  bg.last.withOpacity(0.55),
                                ],
                                stops: const [0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Title inside the circle (black text on the light circle).
                        Padding(
                          padding: EdgeInsets.only(
                            left: 6,
                            right: 6,
                            bottom: circleSize * 0.11,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              item['label'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 10.5),
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                color: const Color(0xFF1A1A1A),
                                shadows: const [
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 4,
                                  ),
                                  Shadow(
                                    color: Colors.white,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
