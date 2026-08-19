import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
import '../widgets/animated_gradient_tag.dart';
import '../widgets/shining_star_badge.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../providers/saved_events_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/dark_category_section.dart';
import '../widgets/dark_glow_header.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/category_icon_card.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/pick_your_pace_row.dart';
import '../widgets/event_card_with_rating.dart';
import '../sections/app_footer.dart';
import '../widgets/app_refresh_indicator.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/all_categories_popup.dart';
import 'program_detail_screen.dart';
import 'events_screen.dart';
import 'classes_screen.dart';
import 'venues_screen.dart';
import 'category_programs_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  int _currentNavIndex = 3;

  // Scroll-driven floating navbar: hidden over the black hero (header → banner →
  // categories), then fades + slides into view as that region scrolls away.
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _navReveal = ValueNotifier<double>(0.0);
  double _navFadeStart = 400;
  double _navFadeEnd = 700;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final double t = ((offset - _navFadeStart) / (_navFadeEnd - _navFadeStart))
        .clamp(0.0, 1.0);
    if (_navReveal.value != t) _navReveal.value = t;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navReveal.dispose();
    super.dispose();
  }

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(
      context,
      DummyData.programsSeeAllCategories,
      lineIcons: true,
      darkBackground: true,
      cardMetrics: CategoryCardMetrics.programs,
      lineIconLabelSize: 11,
      onCategoryTap: (index) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProgramsScreen(
              initialCategoryIndex:
                  index.clamp(0, DummyData.programsCategories.length - 1),
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
    final double screenH = MediaQuery.of(context).size.height;
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    // Tall banner (matches the Venues page): fills the viewport minus the header
    // block and the navbar area.
    final double bannerH = (screenH -
            MediaQuery.of(context).padding.top -
            156 -
            (safeBottom > 0 ? safeBottom + 15 : 30) -
            140)
        .clamp(300.0, 700.0);
    final double bannerCardWidth = MediaQuery.of(context).size.width - 32;

    // Reveal the navbar as the top banner scrolls away (tied to the banner
    // height, not a fixed screen fraction).
    final double heroTop = MediaQuery.of(context).padding.top + 169;
    _navFadeStart = heroTop + bannerH * 0.65;
    _navFadeEnd = heroTop + bannerH;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — header scrolls with body (Session-48 fix).
          AppRefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Black "night theatre" region: header → categories ──
                      ColoredBox(
                        color: Colors.black,
                        child: Column(
                          children: [
                            const DarkGlowHeader(),
                            const SizedBox(height: 14),
                            // Tall banner (matches the Venues page). Black-filled
                            // box behind casts the gold side-glow and backs the
                            // image (no glow bleed through transparent areas).
                            SizedBox(
                              height: bannerH,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Center(
                                    child: Container(
                                      width: bannerCardWidth,
                                      height: bannerH,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: goldBannerSideGlow(),
                                      ),
                                    ),
                                  ),
                                  RepaintBoundary(
                                    child: BannerCarousel(
                                      events: DummyData.programsScreenBanners,
                                      height: bannerH,
                                      showGlow: false,
                                      overlayStyle: true,
                                      ctaText: 'Explore Program',
                                      fixedCardWidth: bannerCardWidth,
                                      cornerRadius: 22,
                                      overlayDots: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            const DarkCategoryTitle('Pave Your Path'),
                            const SizedBox(height: 18),
                            // Grid with the "View All" pill floated over the
                            // bottom row (seamlessly blended).
                            // Reserve space so the floated pill stays INSIDE the
                            // Stack bounds (a Positioned child hanging past the
                            // Stack isn't hit-testable).
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: RepaintBoundary(
                                    child: ExploreCategoriesGrid(
                                      categories: DummyData.programsCategories,
                                      scrollable: true,
                                      visibleRows: 2.3,
                                      maxScrollRows: 3,
                                      lineIcons: true,
                                      cardMetrics: CategoryCardMetrics.programs,
                                      // Programs names are the longest in the
                                      // app ("Leadership & Entrepreneurship"),
                                      // so they need a step down from 12.
                                      lineIconLabelSize: 11,
                                      onCategoryTap: (index) => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CategoryProgramsScreen(
                                            initialCategoryIndex: index,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: DarkViewAllButton(
                                    onTap: () =>
                                        _showAllCategoriesPopup(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                          ],
                        ),
                      ),

                      // ── The Big Leagues ──
                      const SectionDividerWidget(
                        title: 'The Big Leagues',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 548, min: 523),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                              child: EventCardWithRating(
                                event: DummyData.hotPicks[index],
                                buttonLabel: 'View Details',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProgramDetailScreen(event: DummyData.hotPicks[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── Make Your Weekends Count ──
                      const SectionDividerWidget(
                        title: 'Make Your Weekends Count',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 214, min: 200),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.weekendSpecial.length,
                          itemBuilder: (context, index) {
                            final e = DummyData.weekendSpecial[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _buildSideBySideCard(
                                context,
                                event: e,
                                scheduleText: 'Sat & Sun, 10:00 AM',
                                ageText: '8-12 Yrs',
                                locationText: 'Online',
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Find Your Fit ──
                      const SectionDividerWidget(
                        title: 'Find Your Fit',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      PickYourPaceRow(items: DummyData.findYourFit),

                      // ── Zero to Hero ──
                      const SectionDividerWidget(
                        title: 'Zero to Hero',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 214, min: 200),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.newOnTlb.length,
                          itemBuilder: (context, index) {
                            final e = DummyData.newOnTlb[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: _buildSideBySideCard(
                                context,
                                event: e,
                                scheduleText: 'Start with basics of programming',
                                ageText: '8+ Yrs',
                                locationText: e.venue,
                              ),
                            );
                          },
                        ),
                      ),

                      // ── The Holiday Edit ──
                      const SectionDividerWidget(
                        title: 'The Holiday Edit',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 348, min: 322),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.programsHolidayEdit.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildHolidayCard(
                              context,
                              event: DummyData.programsHolidayEdit[index],
                            ),
                          ),
                        ),
                      ),

                      // ── For Unique Minds ──
                      const SectionDividerWidget(
                        title: 'For Unique Minds',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 420, min: 400),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.classesSpecialFocus.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildUniqueMindCard(
                              context,
                              event: DummyData.classesSpecialFocus[index],
                            ),
                          ),
                        ),
                      ),

                      // ── Level Up Your Profile ──
                      const SectionDividerWidget(
                        title: 'Level Up Your Profile',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 30,
                      ),
                      SizedBox(
                        // Card height held constant — the taller image below
                        // grows DOWN into the Spacer gap, filling the white
                        // space between the meta rows and the button.
                        height: Responsive.h(context, 448, min: 424),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.categoryEventsExtra.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildLevelUpCard(
                              context,
                              event: DummyData.categoryEventsExtra[index],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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
            // Hidden over the black hero; fades + slides up as the categories
            // region scrolls away.
            child: ValueListenableBuilder<double>(
              valueListenable: _navReveal,
              builder: (context, t, child) {
                // Apply easing curves so the animation feels organic rather
                // than mechanically linear. Opacity leads (appears early),
                // scale and slide follow a slightly snappier curve.
                final double easedOpacity =
                    Curves.easeOutCubic.transform(t);
                final double easedMotion =
                    Curves.easeOutQuart.transform(t);

                // Scale: the pill starts slightly smaller (0.92) and grows
                // to full size, giving the feel of rising toward the viewer.
                final double scale = 0.92 + 0.08 * easedMotion;

                // Slide: 40px upward travel (down from 60) — enough motion
                // to feel deliberate but not jarring.
                final double slideY = (1 - easedMotion) * 40;

                return IgnorePointer(
                  ignoring: t < 0.05,
                  child: Opacity(
                    opacity: easedOpacity,
                    child: Transform.translate(
                      offset: Offset(0, slideY),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.bottomCenter,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Align(
                alignment: Alignment.center,
                child: FloatingNavbar(
                  currentIndex: _currentNavIndex,
                  onTap: _onNavTapped,
                  bottomPadding: FloatingNavbar.bottomInset(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Side-by-side card (Weekends + Zero to Hero) ──
  Widget _buildSideBySideCard(
    BuildContext context, {
    required EventModel event,
    required String scheduleText,
    required String ageText,
    required String locationText,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
      ),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          // Inset so the image sits inside the card as a separate rounded
          // component (not flush / cut at the card edges).
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image — all corners rounded and widened for more coverage
              // toward the right.
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  event.imagePath,
                  width: Responsive.w(context, 176, min: 150),
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: Responsive.w(context, 176, min: 150),
                    color: AppColors.primary.withOpacity(0.15),
                    child: const Icon(Icons.event, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // The CTA used to close this column; without it the data sat
                  // at the top with the rest of the card blank. Spreading the
                  // rows lets them occupy the card's full height.
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _iconRow(Icons.calendar_month_outlined, scheduleText),
                    _iconRow(Icons.people_outline, ageText),
                    _iconRow(Icons.location_on_outlined, locationText),
                    // Distance from the user (mock display data)
                    _iconRow(Icons.near_me_outlined, event.distanceDisplay,
                    color: AppColors.distanceGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── The Holiday Edit card (large image + camp pill + View Now) ──
  Widget _buildHolidayCard(BuildContext context, {required EventModel event}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
      ),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            // ── Large image (fills the extra card height) + camp pill ──
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        event.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withOpacity(0.15),
                          child: const Center(child: Icon(Icons.event, size: 44)),
                        ),
                      ),
                    ),
                  if ((event.tag ?? '').isNotEmpty)
                    Positioned(
                      top: 12,
                      // Animated red → purple gradient that slides slowly and
                      // continuously across the tag.
                      child: AnimatedGradientTag(
                        text: event.tag!,
                        fontSize: 11.5,
                        period: const Duration(seconds: 6),
                        showChrome: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        borderRadius: BorderRadius.circular(30),
                        gradientColors: const [
                          Color(0xFFE11D48), // red
                          Color(0xFF9333EA), // purple
                          Color(0xFFE11D48), // red (loops seamlessly)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: Responsive.sp(context, 16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Meta in two balanced columns (the CTA that used to close
                  // this card is gone; the whole card is tappable). Age and
                  // schedule sit left, place and distance right — each column
                  // gets ~128pt of text, which clears the longest values.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _iconRow(Icons.child_care_outlined,
                                event.ageGroupDisplay),
                            const SizedBox(height: 7),
                            _iconRow(Icons.calendar_today_outlined,
                                event.dateTimeDisplay),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _iconRow(
                                Icons.location_on_outlined, event.venue),
                            const SizedBox(height: 7),
                            _iconRow(Icons.near_me_outlined,
                                event.distanceDisplay,
                                color: AppColors.distanceGreen),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── For Unique Minds card (star badge top-left) ──
  Widget _buildUniqueMindCard(BuildContext context, {required EventModel event}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
      ),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded so the image fills the space freed by the removed CTA.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.event, size: 40),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: ShiningStarBadge(size: 40),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Two-column meta: Age + Date·Time left, Location +
                    // Distance (green) right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _iconRow(Icons.child_care_outlined,
                                  event.ageGroupDisplay),
                              const SizedBox(height: 7),
                              _iconRow(Icons.calendar_today_outlined,
                                  event.dateTimeDisplay),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _iconRow(Icons.location_on_outlined,
                                  event.venue),
                              const SizedBox(height: 7),
                              _iconRow(Icons.near_me_outlined,
                                  event.distanceDisplay,
                                  color: AppColors.distanceGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Level Up Your Profile card ──
  Widget _buildLevelUpCard(BuildContext context, {required EventModel event}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
      ),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expanded so the image fills the space freed by the removed CTA.
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withOpacity(0.15),
                        child: const Icon(Icons.event, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Portfolio Project : Yes',
                        style: GoogleFonts.poppins(
                          fontSize: Responsive.sp(context, 10),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 16),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (event.description != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              event.description!,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 9),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Meta in two balanced columns: format + age on the left,
                    // certificate + distance on the right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _iconRow(Icons.location_on_outlined,
                                  event.venue.split('\n').first),
                              const SizedBox(height: 7),
                              _iconRow(Icons.child_care_outlined,
                                  event.ageGroupDisplay),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _iconRow(Icons.workspace_premium_outlined,
                                  'Certificate Included'),
                              const SizedBox(height: 7),
                              _iconRow(Icons.near_me_outlined,
                                  event.distanceDisplay,
                                  color: AppColors.distanceGreen),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    // Date runs full width — at 155pt it is the one value that
                    // will not fit a ~130pt half-column without being cut.
                    _iconRow(Icons.calendar_today_outlined, event.dateTimeDisplay),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textPrimary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: Responsive.sp(context, 11.5),
              color: color ?? AppColors.textSecondary,
              fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
