import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive.dart';
import '../../screens/category_detail_screen.dart';

class ExploreCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String currentCategoryTitle;
  final bool showAllCategories;
  final VoidCallback onToggleShowAll;

  const ExploreCategoriesWidget({
    super.key,
    required this.categories,
    required this.currentCategoryTitle,
    required this.showAllCategories,
    required this.onToggleShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final sortedCategories = List<Map<String, dynamic>>.from(categories);
    final activeIndex = sortedCategories.indexWhere((cat) => cat['title'] == currentCategoryTitle);
    if (activeIndex != -1) {
      final activeCat = sortedCategories.removeAt(activeIndex);
      sortedCategories.insert(0, activeCat);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore other Categories',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                TextButton(
                  onPressed: onToggleShowAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showAllCategories ? 'See Less' : 'See All',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        showAllCategories ? Icons.keyboard_arrow_up : Icons.arrow_forward_ios, 
                        size: 12, 
                        color: const Color(0xFF2196F3)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          showAllCategories 
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: sortedCategories.map((cat) => _buildCategoryTile(context, cat)).toList(),
              ),
            )
          : SizedBox(
              height: Responsive.h(context, 140, min: 120),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryTile(context, sortedCategories[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Map<String, dynamic> cat) {
    final colors = cat['colors'] as List<Color>;
    final isCurrentCategory = cat['title'] == currentCategoryTitle;

    final baseWidth = Responsive.w(context, 96, min: 80);
    final width = isCurrentCategory ? baseWidth + 8 : baseWidth;
    final height = isCurrentCategory ? Responsive.h(context, 126, min: 108) : Responsive.h(context, 118, min: 100);
    final borderStrength = isCurrentCategory ? 2.5 : 1.0;

    return GestureDetector(
      onTap: () {
        if (!isCurrentCategory) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryDetailScreen(
                title: cat['title'] as String,
                imagePath: cat['image'] as String,
                backgroundColors: colors,
              ),
            ),
          );
        }
      },
      child: Container(
        width: width,
        height: height,
        margin: showAllCategories ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          border: Border.all(
            color: isCurrentCategory ? const Color(0xFFFFCC00) : Colors.grey.withOpacity(0.15),
            width: borderStrength,
          ),
          boxShadow: isCurrentCategory 
            ? [
                BoxShadow(color: const Color(0xFFFFCC00).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ] 
            : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 4, right: 4),
              child: Text(
                cat['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  cat['image'] as String,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
