import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  /// Extra coloured height below the logo so the footer colour reaches the
  /// screen bottom (covers the floating-navbar clearance, no white gap).
  final double bottomExtra;

  const AppFooter({super.key, this.bottomExtra = 0});

  @override
  Widget build(BuildContext context) {
    // Original footer: main-footer.png (white → gold, black logo) recoloured by
    // a single modulate ShaderMask. The shader holds *pure white* across the
    // top portion (stops [0, 0.4]) so the PNG's white top stays truly white and
    // blends into the white page — no faint cream "box" edge — then fades to the
    // light tint below. The extension uses the PNG's exact bottom colour so it
    // matches seamlessly after the shared shader.
    final footer = ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Color(0xFFFFE2B0)],
        stops: [0.0, 0.4, 1.0],
      ).createShader(rect),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Image.asset(
            'resources- tlb-ui/main-footer.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => const SizedBox(height: 80),
          ),
          Container(height: bottomExtra, color: const Color(0xFFFFCF19)),
        ],
      ),
    );

    // Extra-soft white → transparent veil over the top so the footer dissolves
    // out of the white page with no perceptible boundary.
    return Stack(
      children: [
        footer,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 130,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white.withOpacity(0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
