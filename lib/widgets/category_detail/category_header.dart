import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive.dart';

class CategoryHeader extends StatelessWidget {
  final String title;
  final String imagePath;
  final List<Color> backgroundColors;
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final VoidCallback onBackTap;

  const CategoryHeader({
    super.key,
    required this.title,
    required this.imagePath,
    required this.backgroundColors,
    required this.searchController,
    required this.onFilterTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final double headerHeight = Responsive.h(context, 190, min: 170);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Gradient
        Container(
          height: headerHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: backgroundColors,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        
        // Background Image (Right side)
        Positioned(
          top: MediaQuery.of(context).padding.top,
          right: -20,
          child: Opacity(
            opacity: 0.9,
            child: Image.asset(
              imagePath,
              height: Responsive.h(context, 120, min: 100),
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Back Button & Title
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 10,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
                onPressed: onBackTap,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),

        // Inner Search Bar
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4), // Dynamic translucent background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 3), // 3px white border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Events , Categories & more ..',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF1A1A2E).withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A1A2E), size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFF1A1A2E), size: 20),
                  onPressed: onFilterTap,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
