import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppFooter extends StatelessWidget {
  /// Extra coloured height below the logo so the footer colour reaches the
  /// screen bottom (covers the floating-navbar clearance, no gap).
  final double bottomExtra;

  const AppFooter({super.key, this.bottomExtra = 0});

  // Footer background mirrors the home header's warm gradient. The header runs
  // gold → cream top-to-bottom and dissolves DOWN into the page; the footer is
  // its mirror — it dissolves UP into the page (transparent cream at the top)
  // and deepens to the header's saturated golden tint at the very bottom, so the
  // colour is darkest/strongest exactly where it meets the screen edge.
  static const Color _gold = Color(0xFFFB9512); // golden-orange tint (darkest)
  static const Color _amber = Color(0xFFFFC861);
  static const Color _cream = Color(0xFFFFF0D0); // header's flat cream band

  @override
  Widget build(BuildContext context) {
    final double logoWidth = MediaQuery.of(context).size.width * 0.46;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00FFF0D0), // transparent cream — seamless blend into page
            _cream,
            _amber,
            _gold, // darker golden tint at the bottom edge
          ],
          stops: [0.0, 0.42, 0.74, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 56),
          SvgPicture.asset(
            'assets/icons/the_little_broadway_logo.svg',
            width: logoWidth,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const SizedBox(height: 80),
          ),
          // The gradient (above) fills this trailing space too, so the warm
          // gold reaches the screen edge beneath the floating navbar with no
          // seam. 24px breathing room below the logo + the navbar clearance.
          SizedBox(height: 24 + bottomExtra),
        ],
      ),
    );
  }
}
