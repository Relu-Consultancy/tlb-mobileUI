import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import '../helpers/walkthrough_keys.dart';

class NavbarItemData {
  final String label;
  final String iconPath;

  const NavbarItemData({required this.label, required this.iconPath});
}

const List<NavbarItemData> _navItems = [
  NavbarItemData(label: 'Home', iconPath: 'assets/icons/nav_home.svg'),
  NavbarItemData(label: 'Events', iconPath: 'assets/icons/nav_events.svg'),
  NavbarItemData(label: 'Classes', iconPath: 'assets/icons/nav_classes.svg'),
  NavbarItemData(label: 'Program', iconPath: 'assets/icons/nav_program.svg'),
  NavbarItemData(label: 'Venues', iconPath: 'assets/icons/nav_spaces.svg'),
];

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;
  final Map<int, ShowcaseNavConfig>? showcaseConfigs;

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.bottomPadding = 30,
    this.showcaseConfigs,
  });

  // Dark "night theatre" navbar palette (matches the black home redesign).
  static const Color _pillBg = Color(0xFF0D0D0D);      // near-black pill
  static const Color _pillBorder = Color(0xFF2A2A2A);  // hairline edge
  static const Color _activeChip = Color(0xFF262626);  // selected-tab chip
  static const Color _gold = Color(0xFFF5C042);        // active icon + label
  static const Color _inactiveIcon = Color(0xFF8A8A8A); // muted grey icons

  /// Rendered height of the white pill: icon (22) + item vertical padding
  /// (9·2) + item border (2·2) + pill vertical padding (6·2) + pill border
  /// (2·2) ≈ 60. Fixed in logical px — it does NOT shrink on small screens,
  /// which is exactly why content clearance must be derived from it rather
  /// than from a hard-coded guess.
  static const double pillHeight = 60;

  /// The gap the navbar keeps from the screen bottom (device safe-area inset
  /// plus a little breathing room, or a fixed 30 on devices without an inset).
  /// Pass this as [bottomPadding] so the pill and the content clearance below
  /// stay in sync on every device.
  static double bottomInset(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return safeBottom > 0 ? safeBottom + 15.0 : 30.0;
  }

  /// Total vertical space scrollable content must reserve at its bottom so the
  /// floating pill never overlaps real content. = bottom inset + pill height +
  /// a comfortable [gap]. Adapts to the device, fixing the small-screen
  /// overlap where the old hard-coded `+64` under-reserved by ~8–14px.
  static double clearance(BuildContext context, {double gap = 18}) {
    return bottomInset(context) + pillHeight + gap;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final pill = Container(
      width: screenWidth * 0.92,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: _pillBorder, width: 1),
        color: _pillBg,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth * 0.92 - 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = index == currentIndex;

              final navItemWidget = Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isActive ? _activeChip : Colors.transparent,
                      border: isActive
                          ? Border.all(color: Colors.white.withOpacity(0.06), width: 1)
                          : null,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          item.iconPath,
                          width: 22,
                          height: 22,
                          colorFilter: ColorFilter.mode(
                            isActive ? _gold : _inactiveIcon,
                            BlendMode.srcIn,
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          child: isActive
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    item.label,
                                    style: GoogleFonts.poppins(
                                      color: _gold,
                                      fontWeight: FontWeight.w600, // little bold
                                      fontSize: Responsive.sp(context, 14),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              final config = showcaseConfigs?[index];
              if (config == null) return navItemWidget;

              return Showcase(
                key: config.showcaseKey,
                title: config.title,
                description: config.description,
                overlayOpacity: 0.78,
                tooltipBackgroundColor: AppColors.textPrimary,
                textColor: Colors.white,
                scaleAnimationDuration: const Duration(milliseconds: 350),
                scaleAnimationCurve: Curves.easeInOut,
                movingAnimationDuration: const Duration(milliseconds: 350),
                targetPadding: const EdgeInsets.all(6),
                child: navItemWidget,
              );
            }),
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF242424).withOpacity(0),
            const Color(0xFF000000).withOpacity(0.6),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      padding: EdgeInsets.only(top: 48, bottom: bottomPadding),
      child: Center(child: pill),
    );
  }
}
