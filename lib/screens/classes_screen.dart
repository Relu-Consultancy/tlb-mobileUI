import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/event_card_with_rating.dart';
import '../widgets/class_nearby_card.dart';
import '../widgets/new_on_tlb_card.dart';
import '../widgets/holiday_special_card.dart';
import '../widgets/build_skill_card.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/all_categories_popup.dart';
import 'events_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';
import 'category_classes_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  int _currentNavIndex = 2;
  late final PageController _topPicksController;

  @override
  void initState() {
    super.initState();
    _topPicksController = PageController();
  }

  @override
  void dispose() {
    _topPicksController.dispose();
    super.dispose();
  }

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(
      context,
      DummyData.classesSeeAllCategories,
      onCategoryTap: (index) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryClassesScreen(
              initialCategoryIndex: index % DummyData.classesCategories.length,
            ),
          ),
        );
      },
    );
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EventsScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProgramsScreen()),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VenuesScreen()),
      );
    } else if (index != _currentNavIndex) {
      setState(() => _currentNavIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — header scrolls with body (Session-48 fix).
          SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // Header scrolls with the rest of the page now.
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF5E0),
                              Color(0xFFFFF5E0),
                              Color(0xFFFFFAF0),
                              Colors.white,
                            ],
                            stops: [0.0, 0.55, 0.80, 1.0],
                          ),
                        ),
                        child: const Column(
                          children: [
                            HomeHeader(),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                      // ── Education Banner ────────────────────────────────
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.classesScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                          ctaText: 'Explore Classes',
                        ),
                      ),

                      // ── Let's Begin Here ─────────────────────────────────
                      const SectionDividerWidget(title: "Let's Begin Here"),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.classesCategories,
                          scrollable: true,
                          visibleRows: 2.3,
                          onViewAll: () => _showAllCategoriesPopup(context),
                          onCategoryTap: (index) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryClassesScreen(
                                initialCategoryIndex: index,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── What's Everyone Joining? ──────────────────────────
                      const SectionDividerWidget(title: "What's Everyone Joining?"),
                      SizedBox(
                        height: Responsive.h(context, 380, min: 340),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesWhatEveryoneJoining.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: Responsive.w(context, 240),
                                child: EventCardWithRating(
                                  event: DummyData.classesWhatEveryoneJoining[index],
                                  buttonLabel: 'Check Availability',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Pick Your Pace ────────────────────────────────────
                      const SectionDividerWidget(title: 'Pick Your Pace'),
                      SizedBox(
                        height: 148,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          itemCount: DummyData.pickYourPace.length,
                          itemBuilder: (context, index) {
                            final item = DummyData.pickYourPace[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFF0F4FF),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.07),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Image.asset(
                                          item['image'] as String,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.school_outlined,
                                            size: 36,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      item['label'] as String,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: Responsive.sp(context, 11),
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Right Around You ──────────────────────────────────
                      const SectionDividerWidget(title: 'Right Around You'),
                      SizedBox(
                        height: Responsive.h(context, 420, min: 380),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesRightAroundYou.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ClassNearbyCard(
                                event: DummyData.classesRightAroundYou[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                buttonLabel: 'Check Availability',
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Top Picks For You ─────────────────────────────────
                      const SectionDividerWidget(title: 'Top Picks For You'),
                      SizedBox(
                        height: Responsive.h(context, 130, min: 115),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesTopPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: SizedBox(
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                child: NewOnTlbCard(
                                  event: DummyData.classesTopPicks[index],
                                  buttonLabel: 'Send Enquiry',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _topPicksController,
                          count: DummyData.classesTopPicks.length,
                          effect: const WormEffect(
                            dotHeight: 7,
                            dotWidth: 7,
                            activeDotColor: Color(0xFF1A1A2E),
                            dotColor: Color(0xFFE0E0E0),
                            spacing: 5,
                          ),
                        ),
                      ),

                      // ── Holiday Special ───────────────────────────────────
                      const SectionDividerWidget(title: 'Holiday Special'),
                      SizedBox(
                        height: Responsive.h(context, 400, min: 360),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesHolidaySpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: RepaintBoundary(
                                child: HolidaySpecialCard(
                                  event: DummyData.classesHolidaySpecial[index],
                                  width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                  buttonLabel: 'Send Enquiry',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Build New Skills ──────────────────────────────────
                      const SectionDividerWidget(title: 'Build New Skills'),
                      SizedBox(
                        height: Responsive.h(context, 170, min: 155),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesBuildNewSkills.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: BuildSkillCard(
                                event: DummyData.classesBuildNewSkills[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                ctaLabel: 'Send Enquiry',
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Special Focus ─────────────────────────────────────
                      const SectionDividerWidget(title: 'Special Focus'),
                      SizedBox(
                        height: Responsive.h(context, 430, min: 390),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesSpecialFocus.length,
                          itemBuilder: (context, index) {
                            const tagColors = [
                              Color(0xFFDC2626),
                              Color(0xFF0284C7),
                              Color(0xFF059669),
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ClassNearbyCard(
                                event: DummyData.classesSpecialFocus[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                buttonLabel: 'Join Class',
                                tagColor: tagColors[index % tagColors.length],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const AppFooter(),
                      SizedBox(
                          height: (safeBottom > 0 ? safeBottom + 15.0 : 30.0) +
                              64),
                    ],
                  ),
                ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: FloatingNavbar(
                currentIndex: _currentNavIndex,
                onTap: _onNavTapped,
                bottomPadding: safeBottom > 0 ? safeBottom + 15 : 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
