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

import '../widgets/holiday_special_card.dart';
import '../widgets/new_on_tlb_card.dart';
import '../widgets/online_event_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../widgets/weekend_event_card.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';
import '../widgets/all_categories_popup.dart';
import 'category_events_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int _currentNavIndex = 1; // "Events" tab is index 1
  final PageController _newOnTlbController = PageController();

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(context, DummyData.allCategories);
  }

  @override
  void dispose() {
    _newOnTlbController.dispose();
    super.dispose();
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
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Spotlight Banner — overlay style (rounded, gradient, title + CTA)
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.eventsScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                        ),
                      ),
                      
                      const SectionDividerWidget(title: 'Explore by Categories'),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.exploreCategories,
                          onViewAll: () => _showAllCategoriesPopup(context),
                          onCategoryTap: (index) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryEventsScreen(initialCategoryIndex: index),
                            ),
                          ),
                        ),
                      ),

                      const SectionDividerWidget(title: 'Trending Events'),
                      SizedBox(
                        height: Responsive.h(context, 380, min: 340),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 240,
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
                      SizedBox(
                        height: Responsive.h(context, 190, min: 170),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.weekendSpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: WeekendEventCard(
                                event: DummyData.weekendSpecial[index],
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Holiday Special'),
                      SizedBox(
                        height: Responsive.h(context, 400, min: 360),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.holidaySpecials.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: RepaintBoundary(
                                child: HolidaySpecialCard(
                                  event: DummyData.holidaySpecials[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SectionDividerWidget(title: 'Featured Partners'),
                      SizedBox(
                        height: Responsive.h(context, 470, min: 430),
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
                        height: Responsive.h(context, 190, min: 170),
                        child: PageView.builder(
                          controller: _newOnTlbController,
                          itemCount: DummyData.newOnTlb.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: NewOnTlbCard(
                                event: DummyData.newOnTlb[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _newOnTlbController,
                          count: DummyData.newOnTlb.length,
                          effect: const WormEffect(
                            dotHeight: 7,
                            dotWidth: 7,
                            activeDotColor: Color(0xFF1A1A2E),
                            dotColor: Color(0xFFE0E0E0),
                            spacing: 5,
                          ),
                        ),
                      ),

                      const SectionDividerWidget(title: 'Online Events'),
                      SizedBox(
                        height: Responsive.h(context, 300, min: 270),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.onlineEvents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: OnlineEventCard(
                                event: DummyData.onlineEvents[index],
                              ),
                            );
                          },
                        ),
                      ),

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
