import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../widgets/class_nearby_card.dart';
import '../sections/app_footer.dart';
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
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.programsScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                          ctaText: 'Explore Program',
                        ),
                      ),

                      const SectionDividerWidget(title: 'Pave Your Path'),
                      RepaintBoundary(
                        child: ExploreCategoriesGrid(
                          categories: DummyData.programsCategories,
                          childAspectRatio: 0.62,
                          scrollable: true,
                          visibleRows: 2.3,
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
                      const SectionDividerWidget(title: 'The Big Leagues'),
                      SizedBox(
                        height: Responsive.h(context, 400, min: 360),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
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
                      const SectionDividerWidget(title: 'Make Your Weekends Count'),
                      SizedBox(
                        height: Responsive.h(context, 160, min: 140),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
                                buttonLabel: 'Check Availability',
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Find Your Fit ──
                      const SectionDividerWidget(title: 'Find Your Fit'),
                      PickYourPaceRow(items: DummyData.findYourFit),
                      const SizedBox(height: 24),

                      // ── Zero to Hero ──
                      const SectionDividerWidget(title: 'Zero to Hero'),
                      SizedBox(
                        height: Responsive.h(context, 160, min: 140),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
                      const SizedBox(height: 8),

                      // ── The Holiday Edit ──
                      const SectionDividerWidget(title: 'The Holiday Edit'),
                      SizedBox(
                        height: Responsive.h(context, 430, min: 390),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.hotPicks.length,
                          itemBuilder: (context, index) {
                            const tagColors = [
                              Color(0xFF7C3AED),
                              Color(0xFFDC2626),
                              Color(0xFF059669),
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: ClassNearbyCard(
                                event: DummyData.hotPicks[index],
                                width: Responsive.cardWidth(context, fraction: 0.88, max: 360),
                                buttonLabel: 'Check Availability',
                                tagColor: tagColors[index % tagColors.length],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProgramDetailScreen(event: DummyData.hotPicks[index]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // ── For Unique Minds ──
                      const SectionDividerWidget(title: 'For Unique Minds'),
                      SizedBox(
                        height: Responsive.h(context, 340, min: 300),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
                      const SectionDividerWidget(title: 'Level Up Your Profile'),
                      SizedBox(
                        height: Responsive.h(context, 380, min: 340),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
        width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                width: Responsive.w(context, 120),
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: Responsive.w(context, 120),
                  color: AppColors.primary.withOpacity(0.15),
                  child: const Icon(Icons.event, size: 32),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    _iconRow(Icons.calendar_month_outlined, scheduleText),
                    const SizedBox(height: 3),
                    _iconRow(Icons.people_outline, ageText),
                    const SizedBox(height: 3),
                    _iconRow(Icons.location_on_outlined, locationText),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          buttonLabel,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 11),
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

  // ── For Unique Minds card (star badge top-left) ──
  Widget _buildUniqueMindCard(BuildContext context, {required EventModel event}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProgramDetailScreen(event: event)),
      ),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                    height: Responsive.h(context, 160),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 160),
                      color: AppColors.primary.withOpacity(0.15),
                      child: const Icon(Icons.event, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB902),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (event.reviewCount != null)
                      _iconRow(Icons.people_outline, event.reviewCount!),
                    const SizedBox(height: 2),
                    _iconRow(Icons.location_on_outlined, event.venue),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Check Availability',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600),
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
        width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                    height: Responsive.h(context, 170),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: Responsive.h(context, 170),
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
                        fontWeight: FontWeight.w600,
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
                              fontSize: Responsive.sp(context, 13),
                              fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _iconRow(Icons.location_on_outlined, event.venue.split('\n').first),
                    const SizedBox(height: 2),
                    _iconRow(Icons.workspace_premium_outlined, 'Certificate Included'),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Check Availability',
                          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600),
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
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10.5), color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
