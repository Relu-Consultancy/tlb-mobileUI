import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../core/location_state.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/categories_grid.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/empty_location_widget.dart';
import '../sections/hot_picks_section.dart';
import '../sections/weekend_special_section.dart';
import '../sections/tlb_signature_section.dart';
import '../sections/special_needs_section.dart';
import '../sections/stealers_section.dart';
import '../sections/discover_near_you_section.dart';
import '../sections/family_feels_section.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'events_screen.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    for (final event in DummyData.bannerEvents) {
      precacheImage(AssetImage(event.imagePath), context);
    }
  }

  int _currentNavIndex = 0;

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;
    
    // Only handling Home -> Events routing for now.
    if (index == 1) { // Events
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EventsScreen(),
        ),
      );
    } else if (index == 2) { // Classes
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClassesScreen(),
        ),
      );
    } else if (index == 3) { // Programs
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProgramsScreen(),
        ),
      );
    } else if (index == 4) { // Venues
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VenuesScreen(),
        ),
      );
    } else {
      setState(() {
        _currentNavIndex = index;
      });
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
              // Fixed header at top
              const HomeHeader(),

              // Scrollable feed or Empty State
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: LocationState().selectedCity,
                  builder: (context, city, _) {
                    if (!LocationState().isLocationSupported(city)) {
                      return const EmptyLocationWidget();
                    }
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 120 + safeBottom), // clear navbar
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Spotlight section divider
                            const SectionDividerWidget(title: 'Spotlight'),
                            RepaintBoundary(
                              child: BannerCarousel(
                                events: DummyData.bannerEvents, 
                                height: Responsive.h(context, 380, min: 280),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Categories Grid (3x2 layout)
                            const RepaintBoundary(child: CategoriesGrid()),
                            
                            const SizedBox(height: 8),
                            
                            // Sections
                            const RepaintBoundary(child: HotPicksSection()),
                            const RepaintBoundary(child: WeekendSpecialSection()),
                            const RepaintBoundary(child: DiscoverNearYouSection()),
                            const RepaintBoundary(child: FamilyFeelsSection()),
                            
                            const RepaintBoundary(child: TlbSignatureSection()),
                            const RepaintBoundary(child: SpecialNeedsSection()),
                            const RepaintBoundary(child: StealersSection()),

                            // AppFooter with upward gradient
                            const AppFooter(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: safeBottom > 0 ? safeBottom + 15 : 30, // 15px above native nav
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
