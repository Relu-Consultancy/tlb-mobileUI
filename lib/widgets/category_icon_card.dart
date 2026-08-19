import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

/// Band proportions for a [CategoryIconCard], measured off a design mock. Each
/// value is a share of the card's height, so they hold at any width the grid
/// hands us — which is why the grid pins [aspectRatio] alongside them.
class CategoryCardMetrics {
  /// Card width / height.
  final double aspectRatio;

  /// Space above the icon.
  final double topPad;

  /// The icon's square box — a filled circle when [hasCircle], else the bare
  /// glyph.
  final double iconBox;

  /// Space between the icon and the label.
  final double gap;

  /// Whether the icon sits on a filled pastel circle.
  final bool hasCircle;

  /// Centre the label in the space left below the gap, rather than sitting it
  /// at the top of that space. The Programs mock centres; the others top-align
  /// so one- and two-line names share a first-line baseline.
  final bool labelCentered;

  const CategoryCardMetrics({
    required this.aspectRatio,
    required this.topPad,
    required this.iconBox,
    required this.gap,
    required this.hasCircle,
    this.labelCentered = false,
  });

  // The three mocks each drew a different card box (Events 86x148, Classes
  // 78x156, Programs 107x110), which left the sections visibly mismatched in
  // the app. They now share ONE geometry — the Events card, shortened 20pt from
  // its mock so the dead space under the label is trimmed — and differ only in
  // whether the glyph sits on a circle and how the label is aligned.
  //
  // Sharing the box also evens out the glyphs: each set's artwork fills a
  // comparable share of its square (Events 68-81%, Classes 63-83%,
  // Programs 71-89%), so one icon band renders them at consistent sizes.
  //
  // At a 393pt screen the popup/grid card is 109.7 x 168.8pt:
  //   24.1 top pad / 79.2 icon / 33.3 gap / 32.2 label band.
  // That band clears two lines at 12sp (27.6pt) and at 11sp (25.3pt).
  static const double _aspect = 0.650;
  static const double _top = 0.143;
  static const double _icon = 0.469;
  static const double _gap = 0.197;

  /// Events: glyph on a pastel circle, label top-aligned.
  static const events = CategoryCardMetrics(
    aspectRatio: _aspect,
    topPad: _top,
    iconBox: _icon,
    gap: _gap,
    hasCircle: true,
  );

  /// Classes: bare coloured glyph, label top-aligned.
  static const classes = CategoryCardMetrics(
    aspectRatio: _aspect,
    topPad: _top,
    iconBox: _icon,
    gap: _gap,
    hasCircle: false,
  );

  /// Programs: bare coloured glyph, label centred (its mock centres, and its
  /// names are the longest in the app so they read better balanced).
  static const programs = CategoryCardMetrics(
    aspectRatio: _aspect,
    topPad: _top,
    iconBox: _icon,
    gap: _gap,
    hasCircle: false,
    labelCentered: true,
  );
}

/// Clean line-art category card: an outline glyph — on a pastel circle for
/// Events, bare for Classes — with the label centred beneath it on a white card.
/// [metrics] selects which mock's proportions to use.
///
/// The circle is painted natively so it stays crisp at every device density;
/// only the glyph is a raster asset. Each glyph PNG is a square crop centred on
/// the mock's circle, so drawing it across the full circle box reproduces the
/// mock's glyph size and position exactly — no per-icon nudging needed.
///
/// The glyphs were recovered from a 322px-wide design mock, so the source art is
/// only ~60px per icon. They are isolated onto transparency (no baked-in circle),
/// then upscaled with the stroke edges re-crisped, which is what keeps them from
/// looking soft at render size. Replacing them with the original vector files
/// would be a straight swap — nothing else here would need to change.
class CategoryIconCard extends StatelessWidget {
  /// Category name, shown under the circle (wraps to at most 2 lines).
  final String label;

  /// Line-art glyph asset (square, transparent background). When null a neutral
  /// placeholder glyph is drawn — better than crashing on a category list that
  /// predates these keys.
  final String? iconAsset;

  /// The category's pastel tone. Painted as the circle behind the glyph when
  /// [CategoryCardMetrics.hasCircle], and in every case seeds the card's
  /// gradient wash and its [selected] accent border.
  final Color circleColor;

  /// Which mock's band proportions to lay out with.
  final CategoryCardMetrics metrics;

  /// Label size. The default suits a full-width grid cell; narrower hosts (the
  /// category screen's 86pt chips) need to pass a smaller value — "Communication"
  /// only fits an 86pt card at 9.5.
  final double labelFontSize;

  /// Draws an accent border + glow in the category's own hue. Used by the
  /// category screen's chip row to mark the active category.
  final bool selected;

  final VoidCallback? onTap;

  const CategoryIconCard({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.circleColor,
    this.metrics = CategoryCardMetrics.events,
    this.labelFontSize = 12,
    this.selected = false,
    this.onTap,
  });

  /// Builds a card from one of the category maps used across the app, tolerating
  /// entries that carry no `icon` / `circleColor` (older lists, or a caller that
  /// passes its own data) instead of throwing on the cast.
  factory CategoryIconCard.fromCategory(
    Map<String, dynamic> category, {
    Key? key,
    CategoryCardMetrics metrics = CategoryCardMetrics.events,
    double labelFontSize = 12,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return CategoryIconCard(
      key: key,
      label: (category['label'] as String?) ?? '',
      iconAsset: category['icon'] as String?,
      circleColor: (category['circleColor'] as Color?) ?? _neutralCircle,
      metrics: metrics,
      labelFontSize: labelFontSize,
      selected: selected,
      onTap: onTap,
    );
  }

  static const Color _cardFill = Color(0xFFFEFEFE);
  static const Color _cardBorder = Color(0xFFF0F0F0);
  static const Color _labelColor = Color(0xFF2C2C2C);

  /// Circle tone used when a category carries no `circleColor`.
  static const Color _neutralCircle = Color(0xFFF2F2F4);

  /// How far the card's bottom tone is darkened from [circleColor]. The pastels
  /// are ~96% lightness, so a flat wash of them is invisible; -0.07 reads as a
  /// clear shade while leaving the circle distinct against it (at -0.11 the
  /// circle starts to blend into the card).
  static const double _tintDepth = 0.07;

  /// Darkening for the selected border/glow — enough to register as an accent.
  static const double _accentDepth = 0.22;

  /// Same hue, lower lightness. Used for the gradient's bottom tone and the
  /// selected accent, so both stay tied to the category's own colour.
  static Color _deepen(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;
          final double circle = h * metrics.iconBox;

          final Color accent = _deepen(circleColor, _accentDepth);

          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_cardFill, _deepen(circleColor, _tintDepth)],
              ),
              borderRadius: BorderRadius.circular(w * 0.085),
              border: Border.all(
                color: selected ? accent : _cardBorder,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                SizedBox(height: h * metrics.topPad),
                SizedBox(
                  width: circle,
                  height: circle,
                  child: DecoratedBox(
                    // Classes glyphs are vivid and sit bare on the card; only
                    // the Events mock puts them on a pastel disc.
                    decoration: metrics.hasCircle
                        ? BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                          )
                        : const BoxDecoration(),
                    child: iconAsset == null
                        ? Icon(
                            Icons.category_outlined,
                            size: circle * 0.42,
                            color: Colors.grey.shade400,
                          )
                        : Image.asset(
                            iconAsset!,
                            fit: BoxFit.contain,
                            // Glyphs ship at 384px and the circle renders at
                            // roughly 240px on a 3x phone, so this is a
                            // downscale — high filtering keeps the thin strokes
                            // from breaking up.
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.category_outlined,
                              size: circle * 0.42,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: h * metrics.gap),
                // Unless the mock centres it, the label sits at the top of the
                // remaining band so one- and two-line names share a first-line
                // baseline instead of drifting against each other.
                Expanded(
                  child: Padding(
                    // 4% inset, not more: the longest Events label ("Mind &
                    // Strategy Games") needs 96.6pt for its first line on a
                    // 393pt-wide screen, and a 7% inset left only 94.3pt —
                    // which pushed it to a third line and ellipsised the last
                    // word away.
                    padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                    child: Align(
                      alignment: metrics.labelCentered
                          ? Alignment.center
                          : Alignment.topCenter,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, labelFontSize),
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                          color: _labelColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
