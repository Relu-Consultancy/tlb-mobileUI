import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final pill = Container(
      width: screenWidth * 0.92,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.white,
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
                    padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFCC00) : Colors.transparent,
                      border: isActive ? Border.all(color: Colors.white, width: 2) : null,
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
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF1E293B),
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
                                    style: TextStyle(
                                      color: Color(0xFF1E293B),
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
                tooltipBackgroundColor: const Color(0xFF1A1A2E),
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
