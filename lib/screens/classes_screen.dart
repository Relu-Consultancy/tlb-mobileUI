import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../widgets/shining_star_badge.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../providers/saved_events_state.dart';
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
import '../widgets/footer_quote_carousel.dart';
import '../widgets/app_refresh_indicator.dart';
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

  // Pull-to-refresh: reload live wishlist/saved state and rebuild the feed.
  Future<void> _handleRefresh() async {
    await SavedEventsState.loadFromApi();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — header scrolls with body (Session-48 fix).
          AppRefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Header scrolls with the rest of the page now.
                      Container(
                        // Gradient now extends down to the first section title
                        // (banner included), like the home Spotlight header.
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF5E0),
                              Color(0xFFFFF5E0),
                              Color(0xFFFFFAF0),
                              Color(0xFFFFFAF0),
                              Colors.white,
                            ],
                            stops: [0.0, 0.35, 0.60, 0.95, 1.0],
                          ),
                        ),
                        child: Column(
                          children: [
                            const HomeHeader(
                              // Hide the cloud ShaderMask's 1px bottom fringe
                              // (the faint seam line) by painting this screen's
                              // flat background tone over it — same Home fix.
                              seamCoverColor: Color(0xFFFFF5E0),
                            ),
                            const SizedBox(height: 16),
                            // ── Education Banner — full-bleed (edge to edge). ──
                            RepaintBoundary(
                              child: BannerCarousel(
                                events: DummyData.classesScreenBanners,
                                height: Responsive.h(context, 386, min: 286),
                                showGlow: false,
                                overlayStyle: true,
                                ctaText: 'Explore Classes',
                                // Full width — side edges touch the screen; only
                                // the corners are rounded.
                                fixedCardWidth: MediaQuery.of(context).size.width,
                                cornerRadius: 22,
                                overlayDots: true, // dots overlaid on the banner
                              ),
                            ),

                            // ── Let's Begin Here (title left, See All right) ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Let's Begin Here",
                                    style: GoogleFonts.poppins(
                                      fontSize: Responsive.sp(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3A3A3A), // charcoal
                                    ),
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _showAllCategoriesPopup(context),
                                    child: Row(
                                      children: [
                                        Text(
                                          'See All',
                                          style: GoogleFonts.poppins(
                                            fontSize: Responsive.sp(context, 13),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.seeAllBlue,
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            size: 18, color: AppColors.seeAllBlue),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.classesCategories,
                          scrollable: true,
                          visibleRows: 2.3,
                          maxScrollRows: 3, // Restrict scroll to 3rd row
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
                      const SectionDividerWidget(
                        title: "What's Everyone Joining?",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        height: Responsive.h(context, 442, min: 402),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesWhatEveryoneJoining.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: Responsive.w(context, 240),
                                child: EventCardWithRating(
                                  event: DummyData.classesWhatEveryoneJoining[index],
                                  buttonLabel: 'View Details',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Pick Your Pace ────────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Pick Your Pace',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        // Discs sized so two full circles + a half of the third
                        // are visible, hinting the row scrolls.
                        height: (MediaQuery.of(context).size.width - 32) / 2.5 + 8,
                        child: AutoScrollList(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          itemCount: DummyData.pickYourPace.length,
                          itemBuilder: (context, index) {
                            final item = DummyData.pickYourPace[index];
                            final label = item['label'] as String;

                            LinearGradient getGradient(String lbl) {
                              switch (lbl) {
                                case 'Weekly\nClasses':
                                  return const LinearGradient(colors: [Color(0xFFEAF2FF), Color(0xFFD6E7FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Monthly\nPrograms':
                                  return const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE6C7)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Term Courses':
                                  return const LinearGradient(colors: [Color(0xFFF9F8F2), Color(0xFFF2EFE0)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Bootcamps':
                                  return const LinearGradient(colors: [Color(0xFF7AD6FF), Color(0xFF4DBBFF)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Certification':
                                  return const LinearGradient(colors: [Color(0xFFFFF0E6), Color(0xFFFFDCC4)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Trial Class':
                                  return const LinearGradient(colors: [Color(0xFFC2F6E6), Color(0xFF8CECD1)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
                                case 'Holiday\nCamps':
                                  return const LinearGradient(colors: [Colors.white, Colors.white]);
                                default:
                                  return const LinearGradient(colors: [Color(0xFFF0F4FF), Color(0xFFE0E8FF)]);
                              }
                            }

                            // Two full circles + a half peek of the third,
                            // with tighter spacing between them.
                            final double paceSize =
                                (MediaQuery.of(context).size.width - 32) / 2.5;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: paceSize,
                                height: paceSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: getGradient(label),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.04),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: label == 'Holiday\nCamps' ? 2.0 : 16.0,
                                        ),
                                        child: Transform.scale(
                                          scale: label == 'Holiday\nCamps' ? 1.25 : 1.0,
                                          child: Image.asset(
                                            item['image'] as String,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.school_outlined,
                                              size: 32,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: GoogleFonts.poppins(
                                          fontSize: Responsive.sp(context, 10),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Right Around You ──────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Right Around You',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        height: Responsive.h(context, 412, min: 372),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesRightAroundYou.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ClassNearbyCard(
                                event: DummyData.classesRightAroundYou[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                buttonLabel: null,
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Top Picks For You ─────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Top Picks For You',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        height: Responsive.h(context, 255, min: 235),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesTopPicks.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: SizedBox(
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                child: NewOnTlbCard(
                                  event: DummyData.classesTopPicks[index],
                                  buttonLabel: 'View Details',
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
                            activeDotColor: AppColors.textPrimary,
                            dotColor: Color(0xFFE0E0E0),
                            spacing: 5,
                          ),
                        ),
                      ),

                      // ── Holiday Special ───────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Holiday Special',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        height: Responsive.h(context, 450, min: 410),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesHolidaySpecial.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: RepaintBoundary(
                                child: HolidaySpecialCard(
                                  event: DummyData.classesHolidaySpecial[index],
                                  width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                  buttonLabel: 'View Details',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Build New Skills ──────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Build New Skills',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        // Grown to fit the BuildSkillCard's taller inner height
                        // (now carries the Age/Date·Time/Distance meta rows) —
                        // avoids a BOTTOM OVERFLOW in the fixed-height list.
                        height: Responsive.h(context, 259, min: 244),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesBuildNewSkills.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: BuildSkillCard(
                                event: DummyData.classesBuildNewSkills[index],
                                width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                                ctaLabel: 'View Details',
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Special Focus ─────────────────────────────────────
                      const SectionDividerWidget(
                        title: 'Special Focus',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                      ),
                      SizedBox(
                        height: Responsive.h(context, 490, min: 450),
                        child: AutoScrollList(
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
                              child: Stack(
                                children: [
                                  ClassNearbyCard(
                                    event: DummyData.classesSpecialFocus[index],
                                    width: Responsive.cardWidth(context,
                                        fraction: 0.85, max: 360),
                                    buttonLabel: 'View Details',
                                    tagColor:
                                        tagColors[index % tagColors.length],
                                  ),
                                  // Shining star badge over the card's image.
                                  const Positioned(
                                    top: 10,
                                    left: 10,
                                    child: ShiningStarBadge(size: 40),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const FooterQuoteCarousel(),
                      AppFooter(
                          bottomExtra: FloatingNavbar.clearance(context)),
                    ],
                  ),
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
                bottomPadding: FloatingNavbar.bottomInset(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
