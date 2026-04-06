import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
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
import 'classes_screen.dart';
import 'venues_screen.dart';
import '../widgets/all_categories_popup.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  int _currentNavIndex = 3; // "Programs" tab is index 3

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.programsCategories);
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClassesScreen()),
      );
    } else if (index == 4) {
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
                      // AI Bootcamp Spotlight Banner
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.bannerEvents, // Reuse for layout
                          height: Responsive.h(context, 380, min: 280),
                        ),
                      ),

                      const SectionDividerWidget(title: "Pave Your Path"),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.programsCategories,
                          onViewAll: () => _showAllCategoriesPopup(context),
                        ),
                      ),

                      const SectionDividerWidget(title: "The Big Leagues"),
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

                      const SectionDividerWidget(title: 'Make Your Weekends Count'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final event = DummyData.weekendSpecial[0];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: HorizontalCardWidget(
                              imagePath: event.imagePath,
                              distance: 'Online',
                              title: 'Weekend Coding Classes',
                              location: 'Powai',
                              reviewCount: '3.5k reviews',
                              description: 'Sat & sun, 10:00 AM',
                              buttonText: 'Book Trail',
                              event: event,
                            ),
                          );
                        },
                      ),

                      const SectionDividerWidget(title: 'Find Your Fit'),
                      PickYourPaceRow(items: DummyData.findYourFit),
                      const SizedBox(height: 24),

                      const SectionDividerWidget(title: 'Zero to Hero'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final event = DummyData.newOnTlb[0];
                          return HorizontalCardWidget(
                            imagePath: event.imagePath,
                            distance: '8+ yrs',
                            title: 'Beginner Coding for Kids',
                            location: 'Learn basics of programming',
                            reviewCount: '3.5k reviews',
                            description: 'Start with basics of programming',
                            buttonText: 'Start Leaning',
                            event: event,
                          );
                        },
                      ),

                      const SectionDividerWidget(title: 'The Holiday Edit'),
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

                      const SectionDividerWidget(title: 'For Unique Minds'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final event = DummyData.onlineEvents[0];
                          return HorizontalCardWidget(
                            imagePath: event.imagePath,
                            distance: 'Bandra',
                            title: 'Art Therapy Classes',
                            location: 'Creative Healing Studio',
                            reviewCount: '3.5k reviews',
                            description: '6-12 Yrs',
                            buttonText: 'Enquire Now',
                            event: event,
                          );
                        },
                      ),

                      const SectionDividerWidget(title: 'Level Up Your Profile'),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          final event = DummyData.categoryEventsExtra[0];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              height: 240,
                              child: TrendingCard(
                                events: [
                                  EventModel(
                                    title: 'App development Bootcamp',
                                    venue: 'Online\nCertificate Included',
                                    imagePath: event.imagePath,
                                    rating: 4.8,
                                    reviewCount: '12-16 Yrs',
                                    description: 'Build real android/ios apps from scratch',
                                  )
                                ],
                              ),
                            ),
                          );
                        },
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
