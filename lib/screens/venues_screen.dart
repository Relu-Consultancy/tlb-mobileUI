import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../models/event_model.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import 'events_screen.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'category_venues_screen.dart';
import 'venue_detail_screen.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  final int _currentNavIndex = 4;

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventsScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClassesScreen()));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProgramsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
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
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Banner ──
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.venuesScreenBanners,
                          height: Responsive.h(context, 386, min: 286),
                          showGlow: false,
                          overlayStyle: true,
                          ctaText: 'Explore Now',
                        ),
                      ),

                      // ── What's the Plan? ──
                      _sectionHeader(context, "What's the Plan?", onSeeAll: () => _showCategoriesPopup(context)),
                      _buildWhatsPlanRow(context),

                      // ── For the Big Days ──
                      _sectionHeader(context, 'For the Big Days', subtitle: 'Premium celebration & Events'),
                      SizedBox(
                        height: Responsive.h(context, 298),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesBigDays.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildBigDaysCard(context, DummyData.venuesBigDays[i]),
                          ),
                        ),
                      ),

                      // ── Weekend Plan Sorted ──
                      _sectionHeader(context, 'Weekend Plan Sorted', subtitle: 'Curated high engagement picks'),
                      SizedBox(
                        height: 178,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesWeekendPlan.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildWeekendPlanCard(context, DummyData.venuesWeekendPlan[i]),
                          ),
                        ),
                      ),

                      // ── Close to You ──
                      _sectionHeader(context, 'Close to You', subtitle: 'Top venues near your location'),
                      SizedBox(
                        height: Responsive.h(context, 256),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesCloseToYou.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildCloseToYouCard(context, DummyData.venuesCloseToYou[i]),
                          ),
                        ),
                      ),

                      // ── Out & About ──
                      _sectionHeader(context, 'Out & About', subtitle: 'Casual Outings, no booking needed'),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesOutAndAbout.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildOutAndAboutCard(context, DummyData.venuesOutAndAbout[i]),
                          ),
                        ),
                      ),

                      // ── Get Moving ──
                      _sectionHeader(context, 'Get Moving', subtitle: 'Active & physical fun'),
                      SizedBox(
                        height: Responsive.h(context, 420),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesGetMoving.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildGetMovingCard(context, DummyData.venuesGetMoving[i]),
                          ),
                        ),
                      ),

                      // ── Hand-On Spaces ──
                      _sectionHeader(context, 'Hand-On Spaces', subtitle: 'Creative & experiential learning'),
                      SizedBox(
                        height: 236,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesHandsOn.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildHandsOnCard(context, DummyData.venuesHandsOn[i]),
                          ),
                        ),
                      ),

                      // ── Easy on the Pocket ──
                      _sectionHeader(context, 'Easy on the Pocket', subtitle: 'Low-cost & value picks'),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesEasyPocket.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildEasyPocketCard(context, DummyData.venuesEasyPocket[i]),
                          ),
                        ),
                      ),

                      // ── Headed to the Mall? ──
                      _sectionHeader(context, 'Headed to the Mall?'),
                      SizedBox(
                        height: 278,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesHeadedMall.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildMallCard(context, DummyData.venuesHeadedMall[i]),
                          ),
                        ),
                      ),

                      // ── Your Way, Your Plan ──
                      _sectionHeader(context, 'Your Way, Your Plan'),
                      _buildYourWayRow(context),

                      // ── Thoughtful Spaces ──
                      _sectionHeader(context, 'Thoughtful Spaces'),
                      SizedBox(
                        height: Responsive.h(context, 340),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesThoughtful.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildThoughtfulCard(context, DummyData.venuesThoughtful[i]),
                          ),
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

  // ── Section header ──
  Widget _sectionHeader(BuildContext context, String title, {String? subtitle, VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onSeeAll ?? () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('See All', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: const Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right, size: 16, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VenuesCategoriesSheet(
        categories: DummyData.venuesSeeAllCategories,
        onCategoryTap: (index) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryVenuesScreen(
                initialCategoryIndex: index
                    .clamp(0, DummyData.venuesSeeAllCategories.length - 1),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── What's the Plan? circles ──
  Widget _buildWhatsPlanRow(BuildContext context) {
    final cats = DummyData.venuesSeeAllCategories.take(6).toList();
    return SizedBox(
      height: 148,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        clipBehavior: Clip.none,
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final c = cats[i];
          final colors = List<Color>.from(c['gradient'] as List);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryVenuesScreen(
                  initialCategoryIndex: i,
                ),
              ),
            ),
            child: Padding(
            padding: const EdgeInsets.only(right: 18),
            child: SizedBox(
              width: 82,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circle with overflow image
                  SizedBox(
                    width: 82,
                    height: 104,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Circle background anchored to bottom
                        Positioned(
                          bottom: 0,
                          left: 5,
                          right: 5,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.last.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Image overflowing above the circle
                        Positioned(
                          bottom: 2,
                          child: Image.asset(
                            c['image'] as String,
                            width: 82,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(Icons.place, size: 40, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    c['label'] as String,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  // ── For the Big Days card ──
  Widget _buildBigDaysCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(event.imagePath, height: Responsive.h(context, 140), width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 140), color: Colors.grey.shade200)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.tag != null)
                    Row(children: [
                      _tagPill(event.tag!, const Color(0xFFFFEDD5), const Color(0xFFEA580C)),
                      const SizedBox(width: 6),
                      _tagPill('Premium', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                    ]),
                  const SizedBox(height: 6),
                  Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(height: 3),
                  if (event.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB902)),
                      const SizedBox(width: 3),
                      Text('${event.rating}(${event.reviewCount})', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                    ]),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Book Now', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekend Plan Sorted card (side-by-side) ──
  Widget _buildWeekendPlanCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.asset(event.imagePath, width: Responsive.cardWidth(context, fraction: 0.33), height: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: Responsive.cardWidth(context, fraction: 0.33), color: Colors.grey.shade200)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.tag != null)
                    _tagPill(event.tag!, const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                  const SizedBox(height: 6),
                  Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 3),
                  if (event.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB902)),
                      const SizedBox(width: 3),
                      Text('${event.rating}(${event.reviewCount})', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                    ]),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('View Details', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Close to You card ──
  Widget _buildCloseToYouCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(event.imagePath, height: Responsive.h(context, 140), width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 140), color: Colors.grey.shade200)),
              ),
              if (event.tag != null)
                Positioned(
                  bottom: 10, left: 10,
                  child: _tagPill(event.tag!, const Color(0xFF16A34A), Colors.white),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 3),
                  Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text('Open', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: const Color(0xFF16A34A), fontWeight: FontWeight.w500)),
                    ]),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00),
                          foregroundColor: const Color(0xFF1A1A2E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text('View Venue', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Out & About card (overlay) ──
  Widget _buildOutAndAboutCard(BuildContext context, EventModel event) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(event.imagePath, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.65)],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Get Moving card ──
  Widget _buildGetMovingCard(BuildContext context, Map<String, dynamic> data) {
    final venues = (data['venues'] as List).cast<Map<String, dynamic>>();
    final gradientColors = (data['gradient'] as List).cast<Color>();

    return Container(
      width: Responsive.cardWidth(context, fraction: 0.92, max: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient header with floating sport image ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: Responsive.h(context, 112),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sport image — large, top-right, overflowing
                  Positioned(
                    top: -12,
                    right: 8,
                    child: Image.asset(
                      data['image'] as String,
                      width: 118,
                      height: 118,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sports,
                        color: Colors.white.withOpacity(0.5),
                        size: 64,
                      ),
                    ),
                  ),
                  // Text — left side
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    right: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['sport'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 22),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data['slotsText'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12),
                            color: Colors.white.withOpacity(0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Venue list ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(venues.length, (idx) {
                  final v = venues[idx];
                  final slots = (v['slots'] as List).cast<String>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue info row
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              v['image'] as String,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.place, size: 22, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 13),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(children: [
                                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      v['location'] as String,
                                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Time slot pills
                      Row(
                        children: slots.map((slot) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: const Color(0xFFE8E8E8)),
                            ),
                            child: Text(
                              slot,
                              style: GoogleFonts.poppins(
                                fontSize: Responsive.sp(context, 12),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                      if (idx < venues.length - 1) ...[
                        const SizedBox(height: 14),
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 14),
                      ] else
                        const SizedBox(height: 16),
                    ],
                  );
                }),
                // ── View all venues button ──
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: const Color(0xFF1A1A2E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: Text(
                      'View all venues',
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hand-On Spaces card ──
  Widget _buildHandsOnCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(event.imagePath, height: Responsive.h(context, 148), width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 148), color: Colors.grey.shade200)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 3),
                  Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Text('View Venue', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Easy on the Pocket card ──
  Widget _buildEasyPocketCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(event.imagePath, height: Responsive.h(context, 130), width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 130), color: Colors.grey.shade200)),
              ),
              if (event.tag != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Text(event.tag!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 3),
                  Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: const Color(0xFF1A1A2E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('Visit', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Headed to the Mall card ──
  Widget _buildMallCard(BuildContext context, EventModel event) {
    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(event.imagePath, height: Responsive.h(context, 130), width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 130), color: Colors.grey.shade200)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.tag != null)
                    Row(children: [
                      _tagPill(event.tag!, const Color(0xFFFFF3E0), const Color(0xFFF57C00)),
                      const SizedBox(width: 6),
                      _tagPill('Premium', const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
                    ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (event.description != null) ...[
                      const SizedBox(width: 6),
                      Row(children: [
                        const Icon(Icons.people_outline, size: 12, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(event.description!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), color: Colors.grey.shade500)),
                      ]),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  if (event.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFB902)),
                      const SizedBox(width: 3),
                      Text('${event.rating}(${event.reviewCount})', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                    ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC00),
                          foregroundColor: const Color(0xFF1A1A2E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text('Visit', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Your Way, Your Plan tiles ──
  static const List<Map<String, dynamic>> _yourWayTiles = [
    {'label': 'Hourly Slots',       'image': 'resources- tlb-ui/venues_page/yourway/hourly.png',  'bg': Color(0xFFFDECD6), 'light': true},
    {'label': 'Day Passes &\nTickets', 'image': 'resources- tlb-ui/venues_page/yourway/tickets.png', 'bg': Color(0xFFCCEDE8), 'light': true},
    {'label': 'Private\nRentals',   'image': 'resources- tlb-ui/venues_page/yourway/private.png', 'bg': Color(0xFF1E3A5F), 'light': false},
    {'label': 'DIY Spaces',         'image': 'resources- tlb-ui/venues_page/yourway/DIY.png',     'bg': Color(0xFFF0E6FF), 'light': true},
    {'label': 'Food & Eats',        'image': 'resources- tlb-ui/venues_page/yourway/eat.png',     'bg': Color(0xFFFFECE8), 'light': true},
    {'label': 'Guided Tours',       'image': 'resources- tlb-ui/venues_page/yourway/guided.png',  'bg': Color(0xFFE8F4FD), 'light': true},
    {'label': 'Retreats',           'image': 'resources- tlb-ui/venues_page/yourway/retreat.png', 'bg': Color(0xFFEDF7ED), 'light': true},
    {'label': 'Time Slots',         'image': 'resources- tlb-ui/venues_page/yourway/time.png',    'bg': Color(0xFFFFF3CD), 'light': true},
  ];

  Widget _buildYourWayRow(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _yourWayTiles.length,
        itemBuilder: (ctx, i) {
          final t = _yourWayTiles[i];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _wayTile(
              t['label'] as String,
              t['image'] as String,
              t['bg'] as Color,
              t['light'] as bool,
            ),
          );
        },
      ),
    );
  }

  Widget _wayTile(String label, String imagePath, Color bg, bool lightText) {
    final textColor = lightText ? const Color(0xFF1A1A2E) : Colors.white;
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.place, size: 40, color: textColor.withOpacity(0.4)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6),
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w600, color: textColor),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Thoughtful Spaces card ──
  Widget _buildThoughtfulCard(BuildContext context, EventModel event) {
    final tags = <String>[
      if (event.tag != null) event.tag!,
      if (event.description != null) event.description!,
    ];

    return Container(
      width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlays
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  event.imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200),
                ),
              ),
              // Pink star badge — top left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: Color(0xFFEC4899), shape: BoxShape.circle),
                  child: const Icon(Icons.star_rounded, size: 18, color: Colors.white),
                ),
              ),
              // Tag pills overlaid at bottom of image
              if (tags.isNotEmpty)
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: tags
                        .map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEC4899),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
          // Content below image
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(height: 4),
                  if (event.rating != null)
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB902)),
                      const SizedBox(width: 3),
                      Text(
                        '${event.rating}(${event.reviewCount})',
                        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), color: Colors.grey.shade500),
                      ),
                    ]),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCC00),
                        foregroundColor: const Color(0xFF1A1A2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('View Details', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tag pill helper ──
  Widget _tagPill(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10), fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

// ── All Categories popup sheet ──
class _VenuesCategoriesSheet extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int>? onCategoryTap;

  const _VenuesCategoriesSheet({
    required this.categories,
    this.onCategoryTap,
  });

  @override
  State<_VenuesCategoriesSheet> createState() => _VenuesCategoriesSheetState();
}

class _VenuesCategoriesSheetState extends State<_VenuesCategoriesSheet> {
  late List<Map<String, dynamic>> _filtered;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.categories
          : widget.categories.where((c) => (c['label'] as String).toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearch,
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13)),
                decoration: InputDecoration(
                  hintText: 'Search Categories & more ...',
                  hintStyle: GoogleFonts.poppins(fontSize: Responsive.sp(context, 13), color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'All Categories',
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_filtered.length} Results Found)',
                  style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Grid
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No categories found',
                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 14), color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final cat = _filtered[i];
                      final originalIndex = widget.categories.indexOf(cat);
                      return GestureDetector(
                        onTap: () {
                          if (originalIndex != -1) {
                            widget.onCategoryTap?.call(originalIndex);
                          }
                        },
                        child: _catTile(cat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _catTile(Map<String, dynamic> cat) {
    final colors = (cat['gradient'] as List).cast<Color>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                cat['image'] as String,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.place, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          cat['label'] as String,
          style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}