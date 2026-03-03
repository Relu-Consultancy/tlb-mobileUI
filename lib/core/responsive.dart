import 'package:flutter/material.dart';

/// Responsive sizing utility based on a 393×852 design base (standard iPhone 14).
/// All hardcoded pixel values should flow through these helpers so layouts
/// scale proportionally on every screen size.
class Responsive {
  static const double _designWidth = 393.0;
  static const double _designHeight = 852.0;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Horizontal scaling factor
  static double sw(BuildContext context) => width(context) / _designWidth;

  /// Vertical scaling factor
  static double sh(BuildContext context) => height(context) / _designHeight;

  /// Scale a width value proportionally, clamped to [min].
  static double w(BuildContext context, double value, {double? min}) {
    final v = value * sw(context);
    return min != null && v < min ? min : v;
  }

  /// Scale a height value proportionally, clamped to [min].
  static double h(BuildContext context, double value, {double? min}) {
    final v = value * sh(context);
    return min != null && v < min ? min : v;
  }

  /// Scale font size (based on width factor for consistency).
  static double sp(BuildContext context, double value) {
    final factor = sw(context);
    return (value * factor).clamp(value * 0.8, value * 1.3);
  }

  /// Card width that adapts to screen, with a max cap.
  static double cardWidth(BuildContext context,
      {double fraction = 0.75, double max = 320}) {
    final v = width(context) * fraction;
    return v > max ? max : v;
  }
}
