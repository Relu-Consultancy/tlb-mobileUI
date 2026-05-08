import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';

class CategoryScreenHeader extends StatelessWidget {
  final String title;
  final double safeTop;
  final VoidCallback onBack;
  final VoidCallback? onFilterTap;
  /// Two-stop gradient matching the active category card colors.
  /// Falls back to a soft lavender when null.
  final List<Color>? gradientColors;

  const CategoryScreenHeader({
    super.key,
    required this.title,
    required this.safeTop,
    required this.onBack,
    this.onFilterTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [Color(0xFFF0EDFF), Color(0xFFD9D3FF)];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.first, colors.last],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.hPad(context),
          safeTop + 12,
          Responsive.hPad(context),
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow + centered title
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: onBack,
                    child: const Icon(
                      Icons.arrow_back,
                      size: 22,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Search bar
            Container(
              height: Responsive.h(context, 46, min: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by Events, Categories & more ..',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12.5),
                          color: const Color(0xFF8E8E93),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onFilterTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: onFilterTap != null
                            ? const Color(0xFF5B5BD6)
                            : const Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
