import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

/// The canonical full-width gold CTA pill (Book Now / Register / etc.).
///
/// One place so every section's primary CTA is visually identical: same gold
/// fill, radius, height and "medium bold" (w600) label. Use this instead of
/// hand-rolling a `Material`/`ElevatedButton` per card.
class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
