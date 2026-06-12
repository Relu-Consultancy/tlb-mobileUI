import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
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
                      // ── Programs Banner — full-bleed (edge to edge). ────
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.programsScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                          ctaText: 'Explore Program',
                          // Full width — side edges touch the screen; only the
                          // corners are rounded.
                          fixedCardWidth: MediaQuery.of(context).size.width,
                          cornerRadius: 22,
                          overlayDots: true, // dots overlaid on the banner
                        ),
                      ),

                      const SectionDividerWidget(
                        title: 'Pave Your Path',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Color(0xFF3A3A3A), // charcoal
                        lineLength: 100,
                        lineThickness: 1.5,
                        lineColor: Color(0xFFD4A537), // warm gold
                        topPadding: 45,
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
                        topPadding: 45,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 475, min: 450),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
                              child: EventCardWithRating(
                                event: DummyData.hotPicks[index],
                                buttonLabel: 'Check Availability',
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
                        topPadding: 45,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 212, min: 196),
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
                                buttonLabel: 'Book Now',
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
                        topPadding: 45,
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
                        topPadding: 45,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 212, min: 196),
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
                                buttonLabel: 'Check Availability',
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
                        topPadding: 45,
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
                        topPadding: 45,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 366, min: 342),
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
                        topPadding: 45,
                      ),
                      SizedBox(
                        height: Responsive.h(context, 374, min: 350),
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
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(
                event.imagePath,
                width: Responsive.w(context, 150, min: 132),
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: Responsive.w(context, 150, min: 132),
                  color: AppColors.primary.withOpacity(0.15),
                  child: const Icon(Icons.event, size: 32),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
                          buttonLabel,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12.5),
                            fontWeight: FontWeight.w600,
                          ),
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
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Large image with camp pill at top-center ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Image.asset(
                    event.imagePath,
                    height: Responsive.h(context, 215, min: 192),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 215, min: 192),
                      width: double.infinity,
                      color: AppColors.primary.withOpacity(0.15),
                      child: const Icon(Icons.event, size: 44),
                    ),
                  ),
                  if ((event.tag ?? '').isNotEmpty)
                    Positioned(
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          event.tag!,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11.5),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── Info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                  const SizedBox(height: 8),
                  if ((event.reviewCount ?? '').isNotEmpty)
                    _iconRow(Icons.people_outline, event.reviewCount!),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _iconRow(Icons.location_on_outlined, event.venue)),
                      const SizedBox(width: 8),
                      Material(
                        color: const Color(0xFFFFB902),
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
                              'View Now',
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12.5),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A2E),
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
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
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
                    height: Responsive.h(context, 210, min: 180),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 210, min: 180),
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
                        const SizedBox(height: 9),
                        if (event.reviewCount != null)
                          _iconRow(Icons.people_outline, event.reviewCount!),
                        const SizedBox(height: 7),
                        _iconRow(Icons.location_on_outlined, event.venue),
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
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), fontWeight: FontWeight.w600),
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
          border: Border.all(color: Colors.black.withOpacity(0.5), width: 0.7),
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
                    height: Responsive.h(context, 210, min: 185),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 210, min: 185),
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
                      color: const Color(0xFF2563EB),
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
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
                          'View Now',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), fontWeight: FontWeight.w600),
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

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
