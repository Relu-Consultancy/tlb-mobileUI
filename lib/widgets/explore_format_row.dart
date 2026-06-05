import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class ExploreFormatRow extends StatelessWidget {
  final void Function(int index)? onFormatTap;

  const ExploreFormatRow({super.key, this.onFormatTap});

  /// Big circles: ~3 fit across the width so each disc is large and a 4th
  /// peeks in to hint scrolling — matches the Figma design proportions.
  static const double _visibleCount = 3;
  static const double _sidePadding = 16;
  static const double _gap = 4;

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
        // Size the circle so [_visibleCount] of them + even gaps fill the
        // available width (bigger circles than the old fixed 99 px).
        final double available = constraints.maxWidth - _sidePadding * 2;
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

              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : _gap),
                child: GestureDetector(
                  onTap: () => onFormatTap?.call(index),
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
      },
    );
  }
}
