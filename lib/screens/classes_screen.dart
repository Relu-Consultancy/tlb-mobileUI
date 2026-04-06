import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/pick_your_pace_row.dart';
import '../widgets/event_card_with_rating.dart';
import '../widgets/featured_event_card.dart';
import '../widgets/trending_card.dart';
import '../widgets/horizontal_card_widget.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'events_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';
import '../widgets/all_categories_popup.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  int _currentNavIndex = 2; // "Classes" tab is index 2

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.classesCategories);
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      // Home
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      // Events
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
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
                  padding: EdgeInsets.only(bottom: 120 + safeBottom),
                  child: Column(
                    children: [
                      const SectionDividerWidget(title: ''), // spacing
                      // Education Spotlight Banner
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.bannerEvents, // Reuse for layout demo
                          height: Responsive.h(context, 380, min: 280),
                        ),
                      ),

                      const SectionDividerWidget(title: "Let's Begin Here"),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.classesCategories,
                          onViewAll: () => _showAllCategoriesPopup(context),
                        ),
                      ),

                      const SectionDividerWidget(title: "What's Everyone Joining?"),
                      SizedBox(
                        height: Responsive.h(context, 400, min: 360),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 220,
                                child: EventCardWithRating(
                                  event: DummyData.hotPicks[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Pick Your Pace'),
                      const PickYourPaceRow(items: DummyData.pickYourPace),
                      const SizedBox(height: 24),

                      const SectionDividerWidget(title: 'Right Around You'),
                      SizedBox(
                        height: Responsive.h(context, 300, min: 260),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.weekendSpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 280,
                                child: TrendingCard(
                                  events: [DummyData.weekendSpecial[index]],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Top Picks For You'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 2, // Dummy count
                        itemBuilder: (context, index) {
                          final event = DummyData.categoryEventsExtra[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HorizontalCardWidget(
                              imagePath: event.imagePath,
                              distance: 'Sat, 27 Apr',
                              title: event.title,
                              location: event.venue,
                              reviewCount: '3.5k reviews',
                              description: 'Learn keyboard with fun.',
                              buttonText: 'Book Now',
                              event: event,
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
                            return FeaturedEventCard(event: DummyData.stealers[index]);
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Build New Skills'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final event = DummyData.newOnTlb[0];
                          return HorizontalCardWidget(
                            imagePath: event.imagePath,
                            distance: 'Term Course',
                            title: event.title,
                            location: event.venue,
                            reviewCount: '3.5k reviews',
                            description: 'Learn coding logic and game development.',
                            buttonText: 'Start Coding',
                            event: event,
                          );
                        },
                      ),

                      const SectionDividerWidget(title: 'Specials Focus'),
                      SizedBox(
                        height: Responsive.h(context, 300, min: 260),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.onlineEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: FeaturedEventCard(
                                event: DummyData.onlineEvents[index],
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
