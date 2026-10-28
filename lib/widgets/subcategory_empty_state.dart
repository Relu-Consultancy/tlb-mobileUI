import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/app_snackbar.dart';
import '../core/responsive.dart';

class SubcategoryEmptyState extends StatelessWidget {
  final VoidCallback? onExploreOtherCategories;

  const SubcategoryEmptyState({
    super.key,
    this.onExploreOtherCategories,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hPad = Responsive.hPad(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 40),
      // Nudge the whole empty state up so it sits higher in the viewport.
      // (-55 instead of -75 → the image/content sits 20px lower than before.)
      child: Transform.translate(
        offset: const Offset(0, -55),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'resources- tlb-ui/coming soon.png',
            width: sw * 0.56,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => SizedBox(height: sw * 0.4),
          ),
          const SizedBox(height: 20),
          Text(
            'Coming Soon!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 18),
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: sw * 0.72),
            child: Text(
              "We're working on exciting experiences for you. New options will be available soon. Stay tuned!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12),
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: sw * 0.46,
            child: ElevatedButton(
              onPressed: () {
                AppSnackBar.show(context, "You'll be notified when it's available!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Notify Me',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onExploreOtherCategories ?? () => Navigator.pop(context),
            child: Text(
              'Explore Other Categories',
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 12.5),
                fontWeight: FontWeight.w500,
                color: AppColors.indigo,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.indigo,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
