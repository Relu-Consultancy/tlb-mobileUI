import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../widgets/dark_category_section.dart' show kDarkSectionGold;

/// The coach-mark card for the post-signup home tour.
///
/// Replaces showcaseview's plain title/description bubble (used before via
/// the bare `Showcase(title:, description:)` constructor) with a custom card
/// via `Showcase.withWidget(container: WalkthroughTooltip(...))` — a
/// step-specific icon, an animated progress-dot row, and real Skip/Next
/// controls, matching the app's dark-gold identity (footer, dark sections)
/// instead of a generic tutorial-library look.
class WalkthroughTooltip extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  /// 0-based position in the fixed 7-step sequence.
  final int stepIndex;
  final int totalSteps;

  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WalkthroughTooltip({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
  });

  bool get isLastStep => stepIndex == totalSteps - 1;

  @override
  State<WalkthroughTooltip> createState() => _WalkthroughTooltipState();
}

class _WalkthroughTooltipState extends State<WalkthroughTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _badgePop;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    // A short stagger on top of showcaseview's own scale/fade transition
    // (fixed at 300ms decelerate by Showcase.withWidget) — the icon badge
    // pops first, the text catches up half a beat later, so the card reads
    // as assembling itself rather than just appearing.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
    _badgePop = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.9, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.9, curve: Curves.easeOutCubic),
    ));
  }

  // Re-plays the entrance beat each time showcaseview rebuilds this widget
  // for a new step (same State is not reused across steps — a fresh
  // WalkthroughTooltip is constructed per Showcase.withWidget call — but this
  // guards the case where Flutter reuses the element anyway).
  @override
  void didUpdateWidget(covariant WalkthroughTooltip old) {
    super.didUpdateWidget(old);
    if (old.stepIndex != widget.stepIndex) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = widget.isLastStep;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: Responsive.w(context, 300, min: 260).clamp(260, 320),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16161C),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: kDarkSectionGold.withOpacity(0.28),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: kDarkSectionGold.withOpacity(0.10),
              blurRadius: 40,
              spreadRadius: -6,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon badge + step counter ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleTransition(
                  scale: _badgePop,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kDarkSectionGold.withOpacity(0.24),
                          kDarkSectionGold.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: kDarkSectionGold.withOpacity(0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(widget.icon, color: kDarkSectionGold, size: 22),
                  ),
                ),
                const Spacer(),
                _StepCounter(
                  current: widget.stepIndex + 1,
                  total: widget.totalSteps,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Title + description ──
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 17),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12.5),
                        color: Colors.white.withOpacity(0.68),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Progress dots ──
            _ProgressDots(current: widget.stepIndex, total: widget.totalSteps),
            const SizedBox(height: 16),

            // ── Actions ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLast)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onSkip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 2),
                      child: Text(
                        'Skip tour',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 12.5),
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                GestureDetector(
                  onTap: widget.onNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: kDarkSectionGold,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: kDarkSectionGold.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLast ? 'Got it' : 'Next',
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 13),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCounter extends StatelessWidget {
  final int current;
  final int total;
  const _StepCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$current / $total',
        style: GoogleFonts.poppins(
          fontSize: Responsive.sp(context, 11),
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.55),
        ),
      ),
    );
  }
}

/// Dots for every step; the active one stretches into a pill and turns gold —
/// gives the tour a visible sense of progress rather than an unmarked
/// sequence of taps.
class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return Padding(
          padding: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: active
                  ? kDarkSectionGold
                  : done
                      ? kDarkSectionGold.withOpacity(0.45)
                      : Colors.white.withOpacity(0.16),
            ),
          ),
        );
      }),
    );
  }
}
