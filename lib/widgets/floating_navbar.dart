import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  NavbarItemData(label: 'Spaces', iconPath: 'assets/icons/nav_spaces.svg'),
  NavbarItemData(label: 'Shop', iconPath: 'assets/icons/nav_shop.svg'),
];

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Utilize MediaQuery to ensure responsive max widths.
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth * 0.92,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5E7EB), // Metallic grey light
            Color(0xFFD1D5DB), // Metallic grey slightly darker
            Color(0xFF9CA3AF), // Subdued shade at the very bottom
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ), // subtle inner rim highlight
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFD580) : Colors.transparent,
                      border: isActive ? Border.all(color: Colors.white, width: 2) : null,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: const Color(0xFFFFD580).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : null,
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
                            Color(0xFF1E293B), // Dark slate/metallic
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
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
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
            }),
          ),
        ),
      ),
    );
  }
}
