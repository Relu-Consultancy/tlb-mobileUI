import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';

/// A polished, animated confirmation dialog used app-wide in place of the flat
/// default [AlertDialog]: a tinted icon badge, scale-in entrance, and a
/// styled Cancel / Confirm button pair. Returns `true` when confirmed.
///
/// ```dart
/// final ok = await showAppConfirmDialog(
///   context,
///   title: 'Delete Review',
///   message: 'Are you sure you want to delete this review?',
///   confirmLabel: 'Delete',
///   icon: Icons.delete_outline_rounded,
///   destructive: true,
/// );
/// if (ok) { ... }
/// ```
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: _ConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            icon: icon,
            destructive: destructive,
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// Single-action informational dialog (same look as [showAppConfirmDialog])
/// with one full-width dismiss button.
Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'OK',
  IconData icon = Icons.info_outline_rounded,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Opacity(
        opacity: anim.value.clamp(0.0, 1.0),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
          child: _ConfirmDialog(
            title: title,
            message: message,
            confirmLabel: buttonLabel,
            cancelLabel: '',
            icon: icon,
            destructive: false,
            singleAction: true,
          ),
        ),
      );
    },
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool destructive;
  final bool singleAction;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.destructive,
    this.singleAction = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        destructive ? const Color(0xFFEF4444) : AppColors.primaryLight;
    final Color badgeBg =
        destructive ? const Color(0xFFFDECEC) : const Color(0xFFFFF6D6);
    final Color confirmFg =
        destructive ? Colors.white : AppColors.textPrimary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tinted icon badge
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
                  child: Icon(icon, color: accent, size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: Responsive.sp(context, 13.5),
                    color: Colors.grey.shade600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (!singleAction) ...[
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              cancelLabel,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: confirmFg,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            confirmLabel,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
