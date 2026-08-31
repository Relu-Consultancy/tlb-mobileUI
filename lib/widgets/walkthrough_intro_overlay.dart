import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive.dart';
import 'dark_category_section.dart' show kDarkSectionGold;

/// The very first thing a freshly signed-up customer sees on Home — a beat
/// before the guided coach-mark tour starts. Previously a single pulsing
/// "explore" glyph and a flat "Let's Go →" button; this version previews the
/// four things the tour is about to point at (Events / Classes / Programs /
/// Venues, matching WalkthroughTooltip's own step icons for continuity), and
/// gives the tour an honest name and an exit rather than forcing it.
class WalkthroughIntroOverlay extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WalkthroughIntroOverlay({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<WalkthroughIntroOverlay> createState() =>
      _WalkthroughIntroOverlayState();
}

class _WalkthroughIntroOverlayState extends State<WalkthroughIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  bool _pressed = false;

  static const _chips = [
    (icon: Icons.calendar_month_rounded, label: 'Events'),
    (icon: Icons.school_rounded, label: 'Classes'),
    (icon: Icons.route_rounded, label: 'Programs'),
    (icon: Icons.location_city_rounded, label: 'Venues'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _fade = CurvedAnimation(
        parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss(VoidCallback action) async {
    await _ctrl.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: Colors.black.withOpacity(0.82),
          child: SafeArea(
            child: Center(
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 28, min: 20),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    Responsive.w(context, 26, min: 18),
                    Responsive.h(context, 32, min: 26),
                    Responsive.w(context, 26, min: 18),
                    Responsive.h(context, 22, min: 16),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14141A),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: kDarkSectionGold.withOpacity(0.22),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 52,
                        offset: const Offset(0, 22),
                      ),
                      BoxShadow(
                        color: kDarkSectionGold.withOpacity(0.10),
                        blurRadius: 70,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildIconPath(context),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to\nThe Little Broadway',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 21),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Reprises the footer wordmark's underglow streak, so
                      // the very first screen a new customer sees already
                      // carries the app's visual signature.
                      Container(
                        width: 46,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              kDarkSectionGold,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "One quick guided look and you'll know exactly "
                        'where everything lives — events, classes, '
                        'programs, and venues, all in one place.',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 13),
                          color: Colors.white.withOpacity(0.68),
                          height: 1.65,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      _buildPrimaryButton(context),
                      const SizedBox(height: 14),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _dismiss(widget.onSkip),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Skip for now',
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 12.5),
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Four step-preview chips joined by a thin connecting line — a literal
  /// "path" motif that previews the coach-marks about to run, so the tour
  /// doesn't start as a total surprise.
  Widget _buildIconPath(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_chips.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector
            return Container(
              width: 14,
              height: 1.4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: kDarkSectionGold.withOpacity(0.25),
            );
          }
          final chip = _chips[i ~/ 2];
          final delayStart = 0.10 + (i ~/ 2) * 0.10;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 520 + (i ~/ 2) * 90),
            curve: Interval(delayStart.clamp(0.0, 0.7), 1.0,
                curve: Curves.elasticOut),
            builder: (context, t, child) =>
                Transform.scale(scale: t.clamp(0.0, 1.2), child: child),
            child: _IconPathChip(icon: chip.icon, label: chip.label),
          );
        }),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => _dismiss(widget.onNext),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: kDarkSectionGold,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: kDarkSectionGold.withOpacity(0.32),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Take the Tour',
                style: GoogleFonts.poppins(
                  fontSize: Responsive.sp(context, 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconPathChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IconPathChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kDarkSectionGold.withOpacity(0.22),
                kDarkSectionGold.withOpacity(0.06),
              ],
            ),
            border: Border.all(
              color: kDarkSectionGold.withOpacity(0.45),
              width: 1,
            ),
          ),
          child: Icon(icon, color: kDarkSectionGold, size: 18),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 46,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 9),
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
