/// Design-system spacing constants.
/// Use these instead of raw integers for SizedBox / EdgeInsets values.
/// All values are in logical pixels (dp).
class AppSpacing {
  AppSpacing._();

  // Base scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double section = 48.0;

  // Semantic aliases
  static const double cardPadding = base;
  static const double screenHPad = base;
  static const double sectionGap = xl;
  static const double itemGap = md;
  static const double buttonVPad = md;
  static const double inputVPad = 14.0;
}
