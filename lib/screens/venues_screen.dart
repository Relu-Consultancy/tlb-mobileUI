import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/all_categories_popup.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'events_screen.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final int _currentNavIndex = -1; // No tab active in the 4-item navbar for Venues

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.venuesSeeAllCategories);
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProgramsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 120 + safeBottom),
                  child: Column(
                    children: [
                      const SectionDividerWidget(title: ''), // spacing
                      // Venues Spotlight Banner
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.bannerEvents, // Placeholder
                          height: Responsive.h(context, 380, min: 280),
                        ),
                      ),

                      const SectionDividerWidget(title: "Book memorable experience"),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.venuesSeeAllCategories.length > 6 
                            ? DummyData.venuesSeeAllCategories.sublist(0, 6)
                            : DummyData.venuesSeeAllCategories,
                          onViewAll: () => _showAllCategoriesPopup(context),
                        ),
                      ),

                      const SizedBox(height: 40),
                      const AppFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: safeBottom > 0 ? safeBottom + 15 : 30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: FloatingNavbar(
                currentIndex: _currentNavIndex,
                onTap: _onNavTapped,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
