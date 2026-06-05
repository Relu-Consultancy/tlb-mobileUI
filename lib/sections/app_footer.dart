import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  /// Extra coloured height below the logo so the footer colour reaches the
  /// screen bottom (covers the floating-navbar clearance, no white gap).
  final double bottomExtra;

  const AppFooter({super.key, this.bottomExtra = 0});

  @override
  Widget build(BuildContext context) {
    // The footer PNG fades white → #FFCF19 (its real bottom row). A single
    // modulate ShaderMask recolours the whole footer at once: white stays
    // white (blends into the page), the gold shifts to a light header orange,
    // and the black logo stays black. The extension below is filled with the
    // PNG's exact bottom colour, so after the *shared* shader it recolours to
    // the identical tone — image and extension match seamlessly, no band.
    return ShaderMask(
      blendMode: BlendMode.modulate,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        // Light tint → the gold multiplies to ~#FFB711 (light header orange).
        colors: [Colors.white, Color(0xFFFFE2B0)],
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
          // PNG's exact bottom colour → recolours to the same tone as the
          // image bottom and stretches the colour to the screen edge.
          Container(height: bottomExtra, color: const Color(0xFFFFCF19)),
        ],
      ),
    );
  }
}
