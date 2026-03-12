import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import '../widgets/section_divider_widget.dart';
import '../screens/category_detail_screen.dart';

class BrowseByCategoriesSection extends StatelessWidget {
  const BrowseByCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'title': 'Creative art',
        'image': 'assets/images/new_home/eventcategory1.png',
        'colors': [Colors.white, const Color(0xFFFFEBEB)],
      },
      {
        'title': 'Family Time',
        'image': 'assets/images/new_home/eventcategory2.png',
        'colors': [Colors.white, const Color(0xFFFFE4E1)],
      },
      {
        'title': 'Seasonal Special',
        'image': 'assets/images/new_home/eventcategory3.png',
        'colors': [Colors.white, const Color(0xFFE8F0FE)],
      },
      {
        'title': 'Science & STEM',
        'image': 'assets/images/new_home/eventcategory4.png',
        'colors': [Colors.white, const Color(0xFFE0F7FA)],
      },
      {
        'title': 'Health & Wellness',
        'image': 'assets/images/new_home/eventcategory5.png',
        'colors': [Colors.white, const Color(0xFFFFE4E1)],
      },
      {
        'title': 'Play & Adventure',
        'image': 'assets/images/new_home/eventcategory1.png', // Using fallback since no distinct 6th asset
        'colors': [Colors.white, const Color(0xFFF1F8E9)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDividerWidget(title: 'Browse by categories'),
        SizedBox(
          height: Responsive.h(context, 380, min: 320),
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 180 / 140, // Height / Width
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final colors = cat['colors'] as List<Color>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        title: cat['title'] as String,
                        imagePath: cat['image'] as String,
                        backgroundColors: colors,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: colors,
                    ),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
                        child: Text(
                          cat['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
            },
          ),
        ),
      ],
    );
  }
}
