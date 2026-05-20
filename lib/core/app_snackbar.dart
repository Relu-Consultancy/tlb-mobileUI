import 'package:flutter/material.dart';
import 'responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Centralised SnackBar helpers — ensures consistent styling across all screens.
///
/// Usage:
///   AppSnackBar.show(context, 'Something went wrong');
///   AppSnackBar.error(context, 'Network timeout');
///   AppSnackBar.success(context, 'Saved!');
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(context, message, AppColors.textPrimary, duration);
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(context, message, const Color(0xFFB00020), duration);
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, AppColors.successGreen, duration);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          0,
          AppSpacing.base,
          AppSpacing.base,
        ),
        duration: duration,
      ),
    );
  }
}
