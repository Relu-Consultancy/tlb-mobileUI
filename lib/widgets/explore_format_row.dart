import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';

class ExploreFormatRow extends StatelessWidget {
  final void Function(int index)? onFormatTap;

  const ExploreFormatRow({super.key, this.onFormatTap});

  /// Matches the Figma spec (98.98 px on a 393 px design width). Responsive
  /// scaling keeps the diameter proportional on smaller / larger devices.
  static const double _designCircle = 99;
  static const double _designGap = 14;

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
    final size = Responsive.w(context, _designCircle, min: 72);
    final gap = Responsive.w(context, _designGap, min: 10);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: DummyData.exploreFormats.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> format = entry.value;

          // Per-format scale lets us compensate when a source PNG has no
          // built-in padding (Competition) or has a lot of it (MasterClass).
          // Default 1.0 → render the PNG at the full circle size.
          final double scale = (format['scale'] as double?) ?? 1.0;
          final bool invert = format['invertColors'] == true;

          Widget img = Image.asset(
            format['image'],
            width: size,
            height: size,
            fit: BoxFit.cover,
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

          return GestureDetector(
            onTap: () => onFormatTap?.call(index),
            child: Padding(
              padding: EdgeInsets.only(right: gap),
              child: SizedBox(
                width: size,
                height: size,
                child: ClipOval(child: img),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
