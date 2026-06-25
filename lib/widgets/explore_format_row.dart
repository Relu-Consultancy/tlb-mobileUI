import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';

class ExploreFormatRow extends StatelessWidget {
  final void Function(int index)? onFormatTap;

  const ExploreFormatRow({super.key, this.onFormatTap});

  /// Bigger circles: ~2.5 fill the width (two full discs + a peek of the
  /// third), so each disc is larger.
  static const double _visibleCount = 2.5;
  static const double _sidePadding = 16;
  static const double _gap = 8;

  /// Color-inversion matrix — flips luminance so a white-bg PNG renders
  /// as black-bg without needing a redrawn asset.
  static const _invertMatrix = <double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Subtract only the leading padding so the 3 circles span from the
        // left edge to the right edge — each disc is as large as possible and
        // the 4th no longer peeks in. Exactly [_visibleCount] are visible.
        final double available = constraints.maxWidth - _sidePadding;
        final double size =
            (available - (_visibleCount - 1) * _gap) / _visibleCount;

        final formats = DummyData.exploreFormats;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Row(
            children: formats.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> format = entry.value;
              final bool isLast = index == formats.length - 1;

              // Per-format scale compensates for PNGs with no built-in padding
              // (Competition) or a lot of it (MasterClass).
              final double scale = (format['scale'] as double?) ?? 1.0;
              final bool invert = format['invertColors'] == true;

              Widget img = Image.asset(
                format['image'],
                width: size,
                height: size,
                // Contain (not cover) + no oval clip below → the full artwork
                // shows, including the parts that pop out of the disc.
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category, color: Colors.grey),
                ),
              );

              if (invert) {
                img = ColorFiltered(
                  colorFilter: const ColorFilter.matrix(_invertMatrix),
                  child: img,
                );
              }

              if (scale != 1.0) {
                img = Transform.scale(scale: scale, child: img);
              }

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : _gap),
                child: GestureDetector(
                  onTap: () => onFormatTap?.call(index),
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Whole image (no oval clip) so the artwork pops out of
                        // the disc, like the reference.
                        img,
                        // Format name engraved INSIDE the artwork, near the
                        // bottom. A soft white halo keeps it readable.
                        Positioned(
                          left: size * 0.14,
                          right: size * 0.14,
                          bottom: size * 0.10,
                          child: Text(
                            format['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 11.5),
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                              color: AppColors.textPrimary,
                              shadows: const [
                                Shadow(color: Colors.white, blurRadius: 4),
                                Shadow(color: Colors.white, blurRadius: 8),
                              ],
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
