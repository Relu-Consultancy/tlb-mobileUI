import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class ExploreFormatRow extends StatelessWidget {
  final void Function(int index)? onFormatTap;

  const ExploreFormatRow({super.key, this.onFormatTap});

  static const _invertMatrix = <double>[
    -1,  0,  0, 0, 255,
     0, -1,  0, 0, 255,
     0,  0, -1, 0, 255,
     0,  0,  0, 1,   0,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: DummyData.exploreFormats.asMap().entries.map((entry) {
          final int index = entry.key;
          final Map<String, dynamic> format = entry.value;
          final double scale = (format['scale'] as double?) ?? 1.0;
          final bool invert = format['invertColors'] == true;

          Widget img = Image.asset(
            format['image'],
            width: 84,
            height: 84,
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
              padding: const EdgeInsets.only(right: 14),
              child: SizedBox(
                width: 84,
                height: 84,
                child: ClipOval(child: img),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
