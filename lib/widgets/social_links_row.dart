import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_colors.dart';
import '../core/app_snackbar.dart';

/// The partner's social profiles, shown under their name.
///
/// Only the ones they have actually set are drawn. The API sends
/// `social_links` with an empty string for anything unset, so a partner with
/// Instagram alone gets one mark rather than three, two of which would go
/// nowhere. With none set the row takes no height at all — callers can place
/// it unconditionally.
class SocialLinksRow extends StatelessWidget {
  final String? instagramUrl;
  final String? facebookUrl;
  final String? linkedinUrl;
  final String? websiteUrl;

  /// Brand marks are tinted rather than shipped in brand colours: the source
  /// SVGs are gold, which measures ~2.4:1 on this screen's white ground.
  final Color color;

  const SocialLinksRow({
    super.key,
    this.instagramUrl,
    this.facebookUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.color = AppColors.textPrimary,
  });

  static const _icon = 21.0;

  /// True when the partner has set at least one link, so a caller can skip
  /// the surrounding spacing as well as the row.
  bool get hasAny => _clean(instagramUrl) != null ||
      _clean(facebookUrl) != null ||
      _clean(linkedinUrl) != null ||
      _clean(websiteUrl) != null;

  static String? _clean(String? url) {
    final trimmed = url?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> _open(BuildContext context, String url) async {
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
    // Padding, not a bigger glyph: it lifts the touch target to 45px without
    // making the marks loom under the name.
    Widget wrap(String label, String url, Widget glyph) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: () => _open(context, url),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: glyph,
            ),
          ),
        );

    final marks = <Widget>[
      for (final entry in <List<String?>>[
        ['assets/icons/social_instagram.svg', 'Instagram', instagramUrl],
        ['assets/icons/social_facebook.svg', 'Facebook', facebookUrl],
        ['assets/icons/social_linkedin.svg', 'LinkedIn', linkedinUrl],
      ])
        if (_clean(entry[2]) != null)
          wrap(
            entry[1]!,
            _clean(entry[2])!,
            SvgPicture.asset(
              entry[0]!,
              width: _icon,
              height: _icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
      // A globe rather than a fourth brand mark — there is no logo for
      // "the partner's own site".
      if (_clean(websiteUrl) != null)
        wrap(
          'Website',
          _clean(websiteUrl)!,
          Icon(Icons.language, size: _icon, color: color),
        ),
    ];

    if (marks.isEmpty) return const SizedBox.shrink();

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: marks);
  }
}
