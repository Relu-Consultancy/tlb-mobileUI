import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

enum _ToastType { info, success, error }

/// Centralised toast helpers — themed to match the app's card aesthetic.
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
    _show(context, message, _ToastType.info, duration);
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
  }) {
    _show(context, message, _ToastType.error, duration);
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(context, message, _ToastType.success, duration);
  }

  /// Standardised "this feature isn't ready yet" toast. Pass a [feature]
  /// label (e.g. "Chat with support") to personalise the message.
  static void comingSoon(BuildContext context, [String? feature]) {
    final msg = feature != null && feature.isNotEmpty
        ? '$feature is coming soon. Stay tuned!'
        : 'This feature is coming soon. Stay tuned!';
    _show(context, msg, _ToastType.info, const Duration(seconds: 3));
  }

  static void _show(
    BuildContext context,
    String message,
    _ToastType type,
    Duration duration,
  ) {
    final Color accentColor;
    final IconData icon;

    switch (type) {
      case _ToastType.success:
        accentColor = const Color(0xFF22C55E);
        icon = Icons.check_circle_rounded;
        break;
      case _ToastType.error:
        accentColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;
      case _ToastType.info:
        accentColor = AppColors.primaryLight;
        icon = Icons.info_rounded;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: duration,
          content: _ToastWidget(
            message: message,
            accentColor: accentColor,
            icon: icon,
          ),
        ),
      );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color accentColor;
  final IconData icon;

  const _ToastWidget({
    required this.message,
    required this.accentColor,
    required this.icon,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slideAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: widget.accentColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: widget.accentColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.accentColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: widget.accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
