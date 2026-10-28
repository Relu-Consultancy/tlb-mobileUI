import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import 'category_icon_card.dart';

/// Refined bottom-sheet popup that displays all categories with a search bar.
/// Matches the Classes See All design.
class AllCategoriesPopup extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int>? onCategoryTap;

  /// When true, render each category as just its circular artwork + label
  /// (no rectangular gradient card) — used by the Venues "What's the Plan?"
  /// See All, whose images are already circular.
  final bool circularImages;

  /// When true, render the clean line-art treatment from the design mock — a
  /// pastel circle holding an outline glyph on a white card ([CategoryIconCard])
  /// — instead of the vivid gradient cards. Requires each category to carry
  /// `icon` and `circleColor`. Used by the Events "View All".
  final bool lineIcons;

  /// Which mock's proportions the line-icon cards use. Only consulted when
  /// [lineIcons] is true.
  final CategoryCardMetrics cardMetrics;

  /// Label size for the line-icon cards. Only consulted when [lineIcons] is
  /// true; sections with long category names need a smaller value.
  final double lineIconLabelSize;

  /// Render the sheet on black instead of white — the chrome (handle, search
  /// field, close button, heading) flips to its dark palette. Used by the
  /// Events / Classes / Programs "View All", where the pale category cards
  /// read as lit tiles against the dark ground.
  final bool darkBackground;

  const AllCategoriesPopup({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.circularImages = false,
    this.lineIcons = false,
    this.cardMetrics = CategoryCardMetrics.events,
    this.lineIconLabelSize = 12,
    this.darkBackground = false,
  });

  // ── Dark-sheet palette ──
  /// Sheet ground. Matches the near-black of the app's dark sections rather
  /// than pure black, so the sheet still separates from the dimmed barrier.
  static const Color _darkSheet = Color(0xFF080808);

  /// Fill for the search field and close button on the dark sheet.
  static const Color _darkField = Color(0xFF1C1C1E);

  /// Show this popup as a modal bottom sheet (tall, draggable).
  static void show(
    BuildContext context,
    List<Map<String, dynamic>> categories, {
    ValueChanged<int>? onCategoryTap,
    bool circularImages = false,
    bool lineIcons = false,
    CategoryCardMetrics cardMetrics = CategoryCardMetrics.events,
    double lineIconLabelSize = 12,
    bool darkBackground = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (_) => AllCategoriesPopup(
        categories: categories,
        onCategoryTap: onCategoryTap,
        circularImages: circularImages,
        lineIcons: lineIcons,
        cardMetrics: cardMetrics,
        lineIconLabelSize: lineIconLabelSize,
        darkBackground: darkBackground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Chrome colours, resolved once so the light and dark sheets stay in step.
    final Color sheetColor = darkBackground ? _darkSheet : Colors.white;
    final Color fieldColor =
        darkBackground ? _darkField : const Color(0xFFF3F4F6);
    final Color handleColor =
        darkBackground ? Colors.white.withOpacity(0.22) : Colors.grey.shade300;
    final Color titleColor = darkBackground ? Colors.white : Colors.black;
    final Color iconColor =
        darkBackground ? Colors.white.withOpacity(0.85) : Colors.grey.shade600;
    final Color closeIconColor = darkBackground ? Colors.white : Colors.black87;
    // Slightly lifted from grey.shade500 on dark so the secondary text keeps
    // its contrast against the near-black ground.
    final Color subtleTextColor =
        darkBackground ? const Color(0xFFA1A1AA) : Colors.grey.shade500;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Search Bar Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: iconColor, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            // Set explicitly: the field inherits the app's
                            // light theme, so on the dark sheet the typed text
                            // would otherwise be near-black on near-black.
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 13),
                              color: titleColor,
                            ),
                            cursorColor: titleColor,
                            decoration: InputDecoration(
                              hintText: 'Search Categories & more ..',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 13),
                                color: subtleTextColor,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: fieldColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20, color: closeIconColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Header Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    'All Categories',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 18),
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${categories.length} Results Found)',
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 11),
                      fontWeight: FontWeight.w500,
                      color: subtleTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Scrollable Grid ──
          // shrinkWrap so the sheet only grows as tall as the grid needs
          // (no trailing white space when there are few items); it still
          // scrolls within the 0.85 max-height when there are many.
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                // The mock's cards sit closer together (10px on its 86px card)
                // than the gradient variant's 16.
                crossAxisSpacing: lineIcons ? 12 : 16,
                childAspectRatio:
                    lineIcons ? cardMetrics.aspectRatio : 0.72,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final gradientColors = (category['gradient'] as List<Color>?) ??
                    const [Color(0xFFEFEFEF), Color(0xFFDFDFDF)];

                void handleTap() {
                  Navigator.of(context).pop();
                  onCategoryTap?.call(index);
                }

                // Clean line-art variant (Events "View All") — pastel circle
                // + outline glyph on a white card.
                if (lineIcons) {
                  return CategoryIconCard.fromCategory(
                    category,
                    metrics: cardMetrics,
                    labelFontSize: lineIconLabelSize,
                    onTap: handleTap,
                  );
                }

                // Circular variant — just the (already-circular) artwork +
                // label, matching the section row's circles.
                if (circularImages) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: handleTap,
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(
                            category['image'],
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.place,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category['label'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GestureDetector(
                  onTap: handleTap,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // Full-strength gradient (not a faded/opacity version)
                      // so these cards match the vivid category-card look
                      // used everywhere else in the app (ExploreCategoriesGrid).
                      border: Border.all(
                          color: Colors.black.withOpacity(0.06), width: 0.7),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, gradientColors.last],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            category['label'],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 10),
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                category['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.category_outlined,
                                  size: 30,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
