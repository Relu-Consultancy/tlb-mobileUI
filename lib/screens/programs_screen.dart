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
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/explore_categories_grid.dart';
import '../widgets/pick_your_pace_row.dart';
import '../widgets/event_card_with_rating.dart';
import '../sections/app_footer.dart';
import '../widgets/footer_quote_carousel.dart';
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

  void _showAllCategoriesPopup(BuildContext context) {
    AllCategoriesPopup.show(
      context,
      DummyData.programsSeeAllCategories,
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
                            // ── Programs Banner — full-bleed (edge to edge). ──
                            RepaintBoundary(
                              child: BannerCarousel(
                                events: DummyData.programsScreenBanners,
                                height: Responsive.h(context, 386, min: 286),
                                showGlow: false,
                                overlayStyle: true,
                                ctaText: 'Explore Program',
                                // Full width — side edges touch the screen; only
                                // the corners are rounded.
                                fixedCardWidth: MediaQuery.of(context).size.width,
                                cornerRadius: 22,
                                overlayDots: true, // dots overlaid on the banner
                              ),
                            ),
                            // ── Pave Your Path (title left, See All right) ──
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pave Your Path',
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
                          categories: DummyData.programsCategories,
                          // Match the card length of the Events screen's
                          // "Explore by Categories" section.
                          childAspectRatio: 0.8,
                          scrollable: true,
                          visibleRows: 2.3,
                          maxScrollRows: 3, // scroll stops at the 3rd row
                          imagesFlushBottom: true, // artwork sits at card bottom
                          onViewAll: () => _showAllCategoriesPopup(context),
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

                      // ── The Big Leagues ──
                      const SectionDividerWidget(
                        title: 'The Big Leagues',
                        fontSize: 16,
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
                        fontSize: 16,
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
                                buttonLabel: 'View Details',
                              ),
                            );
                          },
                        ),
                      ),

                      // ── Find Your Fit ──
                      const SectionDividerWidget(
                        title: 'Find Your Fit',
                        fontSize: 16,
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
                        fontSize: 16,
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
                                buttonLabel: 'View Details',
                                smallButton: true,
                              ),
                            );
                          },
                        ),
                      ),

                      // ── The Holiday Edit ──
                      const SectionDividerWidget(
                        title: 'The Holiday Edit',
                        fontSize: 16,
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
                        fontSize: 16,
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
                        fontSize: 16,
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

  // ── Side-by-side card (Weekends + Zero to Hero) ──
  Widget _buildSideBySideCard(
    BuildContext context, {
    required EventModel event,
    required String scheduleText,
    required String ageText,
    required String locationText,
    required String buttonLabel,
    bool smallButton = false,
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
          // component (not flush / cut at the card edges). 18px below the
          // pinned CTA (universal card bottom gap).
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        _iconRow(Icons.calendar_month_outlined, scheduleText),
                        const SizedBox(height: 7),
                        _iconRow(Icons.people_outline, ageText),
                        const SizedBox(height: 7),
                        _iconRow(Icons.location_on_outlined, locationText),
                        const SizedBox(height: 7),
                        // Distance from the user (mock display data)
                        _iconRow(Icons.near_me_outlined, event.distanceDisplay,
                        color: const Color(0xFF1FA85B)),
                      ],
                    ),
                    SizedBox(
                      // Full-width pill; slightly shorter when [smallButton] is
                      // set. The label always stays on one line (FittedBox
                      // scales it down to fit the narrow content column).
                      width: double.infinity,
                      height: smallButton ? 34 : 38,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            buttonLabel,
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, smallButton ? 11.5 : 12.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                      fontSize: Responsive.sp(context, 15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Age Group · Date & Time · Distance (mock display data)
                  _iconRow(Icons.child_care_outlined, event.ageGroupDisplay),
                  const SizedBox(height: 7),
                  _iconRow(Icons.calendar_today_outlined, event.dateTimeDisplay),
                  const SizedBox(height: 7),
                  _iconRow(Icons.near_me_outlined, event.distanceDisplay,
                      color: const Color(0xFF1FA85B)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _iconRow(Icons.location_on_outlined, event.venue)),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                            child: Text(
                              'View Details',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12.5),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    event.imagePath,
                    height: Responsive.h(context, 280, min: 250),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 280, min: 250),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 15),
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
                                      color: const Color(0xFF1FA85B)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'Enquire Now',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    event.imagePath,
                    height: Responsive.h(context, 240, min: 212),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 240, min: 212),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: Responsive.sp(context, 15),
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
                    _iconRow(Icons.location_on_outlined, event.venue.split('\n').first),
                    const SizedBox(height: 7),
                    _iconRow(Icons.workspace_premium_outlined, 'Certificate Included'),
                    const SizedBox(height: 7),
                    // Age Group · Date & Time · Distance (mock display data)
                    _iconRow(Icons.child_care_outlined, event.ageGroupDisplay),
                    const SizedBox(height: 7),
                    _iconRow(Icons.calendar_today_outlined, event.dateTimeDisplay),
                    const SizedBox(height: 7),
                    _iconRow(Icons.near_me_outlined, event.distanceDisplay,
                        color: const Color(0xFF1FA85B)),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
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
