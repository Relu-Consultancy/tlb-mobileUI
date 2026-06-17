import 'dart:math';
import '../core/app_colors.dart';
import 'package:flutter/material.dart';
import '../core/responsive.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppLoader — Premium branded loading indicator for TLB.
///
/// Usage:
///   • Full-screen:  `const AppLoader()`
///   • Inline/small: `const AppLoaderInline()`
///   • Button-size:  `const AppLoaderInline(dotSize: 6, spacing: 4)`
///
/// Fallback system:
///   Set `AppLoader.useCustomLoader = false` to globally revert
///   to the default [CircularProgressIndicator] across the app.
/// ─────────────────────────────────────────────────────────────────────────────

class AppLoader extends StatelessWidget {
  /// Global switch: set to `false` to instantly revert to default loader.
  static bool useCustomLoader = true;

  /// Dot size (diameter). Default 12 for full-screen variant.
  final double dotSize;

  /// Horizontal spacing between dots.
  final double spacing;

  /// Custom color override (defaults to brand yellow).
  final Color? color;

  /// Optional message below the dots.
  final String? message;

  const AppLoader({
    super.key,
    this.dotSize = 12,
    this.spacing = 6,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!useCustomLoader) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.textPrimary,
              strokeWidth: 2.5,
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: Responsive.sp(context, 13),
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StaggeredBounceDots(
            dotSize: dotSize,
            spacing: spacing,
            color: color ?? AppColors.primaryLight,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: Responsive.sp(context, 13),
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact inline variant for buttons, form fields, small containers.
class AppLoaderInline extends StatelessWidget {
  final double dotSize;
  final double spacing;
  final Color? color;

  const AppLoaderInline({
    super.key,
    this.dotSize = 7,
    this.spacing = 4,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!AppLoader.useCustomLoader) {
      return SizedBox(
        width: dotSize * 3,
        height: dotSize * 3,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.textPrimary,
        ),
      );
    }

    return _StaggeredBounceDots(
      dotSize: dotSize,
      spacing: spacing,
      color: color ?? AppColors.textPrimary,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATION CORE
// ─────────────────────────────────────────────────────────────────────────────

class _StaggeredBounceDots extends StatefulWidget {
  final double dotSize;
  final double spacing;
  final Color color;

  const _StaggeredBounceDots({
    required this.dotSize,
    required this.spacing,
    required this.color,
  });

  @override
  State<_StaggeredBounceDots> createState() => _StaggeredBounceDotsState();
}

class _StaggeredBounceDotsState extends State<_StaggeredBounceDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Three brand-tinted dot colors (golden gradient palette)
  static const _dotColors = [
    AppColors.primaryLight, // bright yellow
    AppColors.starAmber, // golden amber
    AppColors.primary, // warm orange
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 0.2 of the cycle
            final offset = i * 0.2;
            final t = (_ctrl.value + offset) % 1.0;

            // Smooth bounce: scale up then down
            final bounce = sin(t * pi);
            final scale = 0.5 + bounce * 0.5; // range 0.5 → 1.0
            final opacity = 0.4 + bounce * 0.6; // range 0.4 → 1.0

            final dotColor = widget.color == AppColors.primaryLight ||
                    widget.color == AppColors.textPrimary
                ? _dotColors[i]
                : widget.color;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withOpacity(0.4 * bounce),
                          blurRadius: widget.dotSize * 0.8 * bounce,
                          spreadRadius: widget.dotSize * 0.1 * bounce,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
