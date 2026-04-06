import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/explore_format_row.dart';
import '../widgets/partner_portrait_card.dart';
import '../widgets/event_card_with_rating.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/trending_card.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';
import '../widgets/all_categories_popup.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentNavIndex = 1; // "Events" tab is index 1

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.allCategories);
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      // Home
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      // Classes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClassesScreen()),
      );
    } else if (index == 3) {
      // Programs
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProgramsScreen()),
      );
    } else if (index == 4) {
      // Venues
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VenuesScreen()),
      );
    } else if (index != _currentNavIndex) {
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
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 120 + safeBottom), // safe space for navbar
                  child: Column(
                    children: [
                      const SectionDividerWidget(title: ''), // spacing
                      // Spotlight Banner
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.bannerEvents, // Assuming first is "Summer Robotics Camp"
                          height: Responsive.h(context, 380, min: 280),
                        ),
                      ),
                      
                      const SectionDividerWidget(title: 'Explore by Categories'),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.exploreCategories,
                          onViewAll: () => _showAllCategoriesPopup(context),
                        ),
                      ),

                      const SectionDividerWidget(title: 'Trending Events'),
                      SizedBox(
                        height: Responsive.h(context, 360, min: 320),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 200,
                                child: EventCardWithRating(
                                  event: DummyData.hotPicks[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Explore by Format'),
                      const RepaintBoundary(child: ExploreFormatRow()),
                      const SizedBox(height: 24),

                      const SectionDividerWidget(title: 'Happening This Weekend'),
                      // Vertical list of wide cards
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: DummyData.weekendSpecial.length,
                        itemBuilder: (context, index) {
                          // Using TrendingCard for a single item visualization, or custom Container.
                          // Wait, TrendingCard is a stateful carousel. I'll just use a simple widget inline or reuse one.
                          // Let's rely on event card
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              height: Responsive.h(context, 160, min: 140),
                              child: TrendingCard(events: [DummyData.weekendSpecial[index]]),
                            ),
                          );
                        },
                      ),

                      const SectionDividerWidget(title: 'Holiday Special'),
                      SizedBox(
                        height: Responsive.h(context, 320, min: 280),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.stealers.length,
                          itemBuilder: (context, index) {
                            return RepaintBoundary(
                              child: FeaturedEventCard(event: DummyData.stealers[index]),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Featured Partners'),
                      SizedBox(
                        height: Responsive.h(context, 280, min: 240),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.featuredPartners.length,
                          itemBuilder: (context, index) {
                            return PartnerPortraitCard(event: DummyData.featuredPartners[index]);
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'New On TLB'),
                      SizedBox(
                        height: Responsive.h(context, 160, min: 140),
                        child: TrendingCard(events: DummyData.newOnTlb),
                      ),
                      const SizedBox(height: 24),

                      const SectionDividerWidget(title: 'Online Events'),
                      SizedBox(
                        height: Responsive.h(context, 360, min: 320),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.onlineEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 200,
                                child: EventCardWithRating(
                                  event: DummyData.onlineEvents[index],
                                ),
                              ),
                            );
                          },
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
