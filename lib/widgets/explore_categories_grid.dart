import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../core/app_colors.dart';
import 'category_icon_card.dart';

class ExploreCategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final VoidCallback? onViewAll;
  final ValueChanged<int>? onCategoryTap;
  final double childAspectRatio;
  final bool scrollable;
  final double visibleRows;
  /// When provided, skips LayoutBuilder and uses this exact height for the grid container.
  final double? scrollHeight;

  /// When set (scrollable mode), caps how many rows of cards are scrollable —
  /// e.g. `maxScrollRows: 3` stops the scroll at the 3rd row. The full list is
  /// still reachable via "View All".
  final int? maxScrollRows;

  /// When true the category image extends to the card's bottom edge (no bottom
  /// padding) so the artwork sits flush at the bottom instead of floating.
  final bool imagesFlushBottom;

  /// When true, render the clean line-art treatment from the design mock — a
  /// pastel circle holding an outline glyph on a white card ([CategoryIconCard])
  /// — instead of the gradient artwork cards. Requires each category to carry
  /// `icon` and `circleColor`. Used by the Events screen.
  ///
  /// Note this also pins the grid's aspect ratio (see [_effectiveAspectRatio]).
  final bool lineIcons;

  /// Which mock's proportions the line-icon cards use. Only consulted when
  /// [lineIcons] is true. Events glyphs sit on a pastel circle; Classes glyphs
  /// are bare and the card is a touch narrower.
  final CategoryCardMetrics cardMetrics;

  /// Label size for the line-icon cards. Only consulted when [lineIcons] is
  /// true. Sections with long category names need a smaller value than the
  /// default so nothing spills past two lines.
  final double lineIconLabelSize;

  const ExploreCategoriesGrid({
    super.key,
    required this.categories,
    this.onViewAll,
    this.onCategoryTap,
    this.childAspectRatio = 0.75,
    this.scrollable = false,
    this.visibleRows = 2.3,
    this.scrollHeight,
    this.maxScrollRows,
    this.imagesFlushBottom = false,
    this.lineIcons = false,
    this.cardMetrics = CategoryCardMetrics.events,
    this.lineIconLabelSize = 12,
  });

  /// [CategoryIconCard] lays its icon, gap and label out as fractions of a card
  /// whose width/height is [CategoryCardMetrics.aspectRatio], so in line-icon
  /// mode the grid pins that ratio rather than trusting the caller's
  /// [childAspectRatio] — a mismatch would silently distort those bands.
  double get _effectiveAspectRatio =>
      lineIcons ? cardMetrics.aspectRatio : childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
      child: scrollable ? _buildScrollableGrid() : _buildStaticGrid(context),
    );
  }

  Widget _buildScrollableGrid() {
    const crossAxisCount = 3;
    const mainAxisSpacing = 12.0;
    const crossAxisSpacing = 12.0;

    // Show exactly 2 complete rows of cards (no partial 3rd row peeking). The
    // full category list is reachable from the section header's "See All".
    const visibleRowCount = 2;
    final int itemCount =
        categories.length < visibleRowCount * crossAxisCount
            ? categories.length
            : visibleRowCount * crossAxisCount;

    // A fixed, non-scrolling 2-row grid.
    final grid = GridView.builder(
      primary: false,
      shrinkWrap: true,
      // ── Scroll disabled (kept for reference) ───────────────────────────
      // Previously this grid scrolled through up to `maxScrollRows` rows with a
      // bouncing physics and a bottom fade hint; now it shows a fixed 2 rows
      // and the rest opens from the header "See All". To restore scrolling,
      // swap the physics back to `const BouncingScrollPhysics()`, restore the
      // `maxScrollRows`-capped itemCount, and re-add the `bottom: 48` padding.
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: _effectiveAspectRatio,
      ),
      itemBuilder: (context, index) => _buildCategoryCard(context, index),
    );

    // ── Seamless bottom-fade blend (kept for reference) ──────────────────
    // The grid's bottom edge used to dissolve to transparent via a ShaderMask
    // so the cut-off row blended into the background (hinting "scroll for
    // more"). Disabled now that the grid shows a fixed 2 rows. To restore,
    // wrap `grid` in the ShaderMask below and give it a fixed height
    // (scrollHeight / visibleRows-derived, as before):
    //
    //   return ShaderMask(
    //     blendMode: BlendMode.dstIn,
    //     shaderCallback: (rect) => const LinearGradient(
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       colors: [Colors.white, Colors.white, Colors.transparent],
    //       stops: [0.0, 0.72, 1.0],
    //     ).createShader(rect),
    //     child: grid,
    //   );
    //
    // The overlaid "View All" chip (_viewAllChip) that used to float at the
    // bottom of the fade now lives in each screen's section header instead.
    return grid;
  }

  // Fully expanded non-scrollable grid (used by Events / Classes screens)
  Widget _buildStaticGrid(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        GridView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: _effectiveAspectRatio,
          ),
          itemBuilder: (context, index) => _buildCategoryCard(context, index),
        ),
        if (onViewAll != null)
          Positioned(
            bottom: 8,
            child: GestureDetector(
              onTap: onViewAll,
              child: _viewAllChip(),
            ),
          ),
      ],
    );
  }

  Widget _viewAllChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View All',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward, size: 14, color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, int index) {
    final category = categories[index];

    // Clean line-art variant — pastel circle + outline glyph on a white card.
    if (lineIcons) {
      return CategoryIconCard.fromCategory(
        category,
        metrics: cardMetrics,
        labelFontSize: lineIconLabelSize,
        onTap: () => onCategoryTap?.call(index),
      );
    }

    final gradientColors = (category['gradient'] as List<Color>?) ??
        const [Color(0xFFEFEFEF), Color(0xFFDFDFDF)];
    final imageInset = (category['imageInset'] as double?) ?? 6.0;
    final imageScale = (category['imageScale'] as double?) ?? 1.0;

    return GestureDetector(
      onTap: () => onCategoryTap?.call(index),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Very slight light hairline around each category card.
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.7),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, gradientColors.last],
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 10, 8, imagesFlushBottom ? 0 : 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Auto-shrink long labels (e.g. "Entrepreneurship") so the last
              // character never wraps to a stray extra line. Honours the
              // forced `\n` line breaks; only scales down when a line overflows.
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category['label'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(imageInset, imageInset, imageInset, imagesFlushBottom ? 0 : 2),
                  child: ClipRect(
                    child: Transform.scale(
                      scale: imageScale,
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        category['image'],
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.category, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
