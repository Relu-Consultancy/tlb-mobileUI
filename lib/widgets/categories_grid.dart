import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/dummy_data.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Top row: 3 items
    final topRowCategories = DummyData.homeCategories.sublist(0, 3);
    // Bottom row: 2 wide items
    final bottomRowCategories = DummyData.homeCategories.sublist(3, 5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: topRowCategories.map((cat) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: cat == topRowCategories.last ? 0 : 12,
                  ),
                  child: _buildCategoryCard(
                    imagePath: cat['image'],
                    label: cat['label'],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: bottomRowCategories.map((cat) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: cat == bottomRowCategories.last ? 0 : 12,
                  ),
                  child: _buildCategoryCard(
                    imagePath: cat['image'],
                    label: cat['label'],
                    isWide: true,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String imagePath,
    required String label,
    bool isWide = false,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5), // Light grey background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  imagePath,
                  height: 70,
                  fit: BoxFit.contain,
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }
}
