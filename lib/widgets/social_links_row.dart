import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';

/// Instagram · Facebook · LinkedIn glyphs, shown under an organizer's name.
///
/// The API returns no social links yet, so every URL is null today and the
/// icons stand as placeholders. They are still wired end to end: pass a URL
/// and that icon opens it. Nothing here needs revisiting when the revised
/// backend starts sending links — only [ApiProvider] does the reading, and
/// it already looks for them.
class SocialLinksRow extends StatelessWidget {
  final String? instagramUrl;
  final String? facebookUrl;
  final String? linkedinUrl;

  /// Brand marks are tinted rather than shipped in brand colours: the source
  /// SVGs are gold, which measures ~2.4:1 on this screen's white ground.
  final Color color;

  const SocialLinksRow({
    super.key,
    this.instagramUrl,
    this.facebookUrl,
    this.linkedinUrl,
    this.color = AppColors.textPrimary,
  });

  static const _icon = 21.0;

  Future<void> _open(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      // Says why nothing happened. A tap that silently does nothing reads as
      // a broken button; this line goes away once the links are real.
      AppSnackBar.show(context, 'Link coming soon');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) AppSnackBar.error(context, 'Could not open link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button(String asset, String label, String? url) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: () => _open(context, url),
            behavior: HitTestBehavior.opaque,
            // Padding, not a bigger glyph: it lifts the touch target to 45px
            // without making the marks loom under the name.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SvgPicture.asset(
                asset,
                width: _icon,
                height: _icon,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        button('assets/icons/social_instagram.svg', 'Instagram', instagramUrl),
        button('assets/icons/social_facebook.svg', 'Facebook', facebookUrl),
        button('assets/icons/social_linkedin.svg', 'LinkedIn', linkedinUrl),
      ],
    );
  }
}
