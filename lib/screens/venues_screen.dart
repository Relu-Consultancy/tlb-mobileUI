import 'package:flutter/material.dart';
import '../widgets/auto_scroll_list.dart';
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
import '../widgets/listing_meta_rows.dart';
import '../sections/app_footer.dart';
import '../widgets/app_refresh_indicator.dart';
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

  // Scroll-driven floating navbar: hidden over the black hero (header → banner →
  // "What's the Plan?"), then fades + slides into view as it scrolls away.
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

  // Pull-to-refresh: reload live wishlist/saved state and rebuild the feed.
  Future<void> _handleRefresh() async {
    await SavedEventsState.loadFromApi();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;
    final safeBottom = MediaQuery.of(context).padding.bottom;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Black "night theatre" region: header → banner →
                      //    What's the Plan? ──
                      ColoredBox(
                        color: Colors.black,
                        child: Column(
                          children: [
                            const DarkGlowHeader(),
                            const SizedBox(height: 14),
                            // Tall banner with a black backing + gold side-glow.
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
                                      events: DummyData.venuesScreenBanners,
                                      height: bannerH,
                                      showGlow: false,
                                      overlayStyle: true,
                                      ctaText: 'Explore Now',
                                      fixedCardWidth: bannerCardWidth,
                                      cornerRadius: 22,
                                      overlayDots: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 26),
                            const DarkCategoryTitle("What's the Plan?"),
                            const SizedBox(height: 18),
                            _buildWhatsPlanRow(context),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),

                      // ── For the Big Days ──
                      _sectionHeader(context, 'For the Big days'),
                      SizedBox(
                        height: Responsive.h(context, 420, min: 400),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesBigDays.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildBigDaysCard(context, DummyData.venuesBigDays[i]),
                          ),
                        ),
                      ),

                      // ── Weekend Plan Sorted ──
                      _sectionHeader(context, 'Weekend Plan Sorted'),
                      SizedBox(
                        height: Responsive.h(context, 196, min: 182),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesWeekendPlan.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildWeekendPlanCard(context, DummyData.venuesWeekendPlan[i]),
                          ),
                        ),
                      ),

                      // ── Close to You ──
                      _sectionHeader(context, 'Close to you'),
                      SizedBox(
                        // Taller so the image can extend further down while the
                        // title/location below keep their room.
                        height: Responsive.h(context, 312, min: 296),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesCloseToYou.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildCloseToYouCard(context, DummyData.venuesCloseToYou[i]),
                          ),
                        ),
                      ),

                      // ── Out & About ──
                      _sectionHeader(context, 'Out & About'),
                      SizedBox(
                        height: Responsive.h(context, 234, min: 218),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesOutAndAbout.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildOutAndAboutCard(context, DummyData.venuesOutAndAbout[i]),
                          ),
                        ),
                      ),

                      // ── Get Moving ──
                      _sectionHeader(context, 'Get Moving'),
                      SizedBox(
                        height: Responsive.h(context, 504, min: 488),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesGetMoving.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildGetMovingCard(context, DummyData.venuesGetMoving[i]),
                          ),
                        ),
                      ),

                      // ── Hand-On Spaces ──
                      _sectionHeader(context, 'Hand-On Space'),
                      SizedBox(
                        height: Responsive.h(context, 304, min: 290),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesHandsOn.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildHandsOnCard(context, DummyData.venuesHandsOn[i]),
                          ),
                        ),
                      ),

                      // ── Easy on the Pocket ──
                      _sectionHeader(context, 'Easy on the pocket'),
                      SizedBox(
                        // +8 to absorb the larger 18px card bottom gap.
                        height: Responsive.h(context, 304, min: 290),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesEasyPocket.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _buildEasyPocketCard(context, DummyData.venuesEasyPocket[i], i),
                          ),
                        ),
                      ),

                      // ── Headed to the Mall? ──
                      _sectionHeader(context, 'Headed to the Mall'),
                      SizedBox(
                        height: Responsive.h(context, 362, min: 344),
                        child: AutoScrollList(
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
                        height: Responsive.h(context, 432, min: 408),
                        child: AutoScrollList(
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: DummyData.venuesThoughtful.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: _buildThoughtfulCard(context, DummyData.venuesThoughtful[i]),
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
            // Hidden over the black hero; fades + slides up as it scrolls away.
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

  Widget _sectionHeader(BuildContext context, String title) {
    return SectionDividerWidget(
      title: title,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      textColor: const Color(0xFF3A3A3A), // charcoal
      lineLength: 100,
      lineThickness: 1.5,
      lineColor: const Color(0xFFD4A537), // warm gold
      topPadding: 30,
    );
  }

  // ── What's the Plan? circles ──
  /// Same hue, lower lightness — the bottom stop of each circle's wash.
  static Color _deepenTint(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Widget _buildWhatsPlanRow(BuildContext context) {
    final cats = DummyData.venuesSeeAllCategories.take(6).toList();
    // Circles trimmed from 152 and spaced a clean 10px apart (they used to
    // overflow their slot to sit almost edge-to-edge).
    const double circle = 120;
    const double gap = 10;

    return SizedBox(
      height: 174,
      child: AutoScrollList(
        padding: const EdgeInsets.only(left: 16),
        clipBehavior: Clip.none,
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final c = cats[i];
          final Color tint =
              (c['circleColor'] as Color?) ?? const Color(0xFFF3F4F6);

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryVenuesScreen(initialCategoryIndex: i),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(right: i == cats.length - 1 ? 0 : gap),
              child: SizedBox(
                width: circle,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: circle,
                      height: circle,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft golden glow behind the circle.
                          Container(
                            width: circle * 0.86,
                            height: circle * 0.86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kDarkSectionGold.withOpacity(0.38),
                                  blurRadius: 24,
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                          ),
                          // The artwork carries its own circle, so the gradient
                          // is laid over it: that deepens the pale fill toward
                          // the bottom while leaving the dark line-work alone
                          // (a plain overlay would wash the strokes out too).
                          //
                          // `modulate`, not `multiply`: both give src x dst
                          // where the two overlap, but `multiply` composites
                          // source-over outside the artwork, so the gradient
                          // flooded the PNG's transparent corners and the
                          // circles read as squares. `modulate` multiplies
                          // alpha as well, so it can't paint outside the disc.
                          ShaderMask(
                            blendMode: BlendMode.modulate,
                            shaderCallback: (rect) => LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                _deepenTint(tint, 0.10),
                              ],
                            ).createShader(rect),
                            child: Image.asset(
                              c['image'] as String,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Icon(Icons.place,
                                  size: 48, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      c['label'] as String,
                      // White — this row sits on the black hero region.
                      style: GoogleFonts.poppins(
                        fontSize: Responsive.sp(context, 12),
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        // Portrait card — taller than it is wide.
        width: Responsive.cardWidth(context, fraction: 0.72, max: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Large image with tag pills inside the bottom-left — Expanded
            // so it fills the space freed by the removed CTA button. ──
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.asset(
                      event.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Row(
                      children: [
                        if ((event.tag ?? '').isNotEmpty)
                          _bigDayPill(event.tag!, const Color(0xFFDB2777), Colors.white, small: true),
                        if ((event.tag ?? '').isNotEmpty) const SizedBox(width: 6),
                        _bigDayPill('Premium', const Color(0xFFFFC107), AppColors.textPrimary, small: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Two-column meta (like the other cards): Age + Date·Time
                  // left, Location + Distance (green) right.
                  ListingMetaRows(
                    event: event,
                    showLocation: true,
                    twoColumn: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filled pill used on the "For the Big Days" image (Birthday / Premium).
  Widget _bigDayPill(String label, Color bgColor, Color textColor, {bool small = false}) {
    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5)
          : const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: small ? 4 : 6, offset: const Offset(0, 2))],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: Responsive.sp(context, small ? 9.5 : 11), fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }

  // ── Weekend Plan Sorted card (side-by-side) ──
  Widget _buildWeekendPlanCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(event.imagePath, width: Responsive.w(context, 148, min: 130), height: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: Responsive.w(context, 148, min: 130), color: Colors.grey.shade200)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if ((event.tag ?? '').isNotEmpty)
                      _bigDayPill(event.tag!, const Color(0xFF16A34A), Colors.white),
                    const SizedBox(height: 9),
                    Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.calendar_month_outlined, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Close to You card ──
  Widget _buildCloseToYouCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(event.imagePath, height: Responsive.h(context, 230, min: 210), width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 230, min: 210), color: Colors.grey.shade200)),
                ),
                if ((event.tag ?? '').isNotEmpty)
                  Positioned(
                    bottom: 10, left: 10,
                    child: _bigDayPill(event.tag!, const Color(0xFF16A34A), Colors.white),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 9, color: Color(0xFF16A34A)),
                        const SizedBox(width: 5),
                        Text('Open', style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: const Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Out & About card (portrait overlay) ──
  Widget _buildOutAndAboutCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: Responsive.cardWidth(context, fraction: 0.45, max: 185),
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
                      colors: [Colors.transparent, Colors.black.withOpacity(0.70)],
                      stops: const [0.40, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 18, left: 14, right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Get Moving card ──
  Widget _buildGetMovingCard(BuildContext context, Map<String, dynamic> data) {
    final venues = (data['venues'] as List).cast<Map<String, dynamic>>();
    final gradientColors = (data['gradient'] as List).cast<Color>();

    void openVenue(Map<String, dynamic> v) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VenueDetailScreen(
              event: EventModel(
                title: data['sport'] as String,
                venue: v['location'] as String,
                imagePath: v['image'] as String,
                listingType: 'venue',
              ),
            ),
          ),
        );

    final card = Container(
      width: Responsive.cardWidth(context, fraction: 0.85, max: 360),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
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
              height: Responsive.h(context, 118),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradientColors.first, Colors.white],
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Sport image — top-right.
                  Positioned(
                    top: 12,
                    right: 20,
                    child: Image.asset(
                      data['image'] as String,
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sports,
                        color: Colors.white.withOpacity(0.7),
                        size: 56,
                      ),
                    ),
                  ),
                  // Text — left side
                  Positioned(
                    left: 18,
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
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data['slotsText'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: Responsive.sp(context, 12.5),
                            color: const Color(0xFF4B5563),
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
          // Expanded so this block fills the remaining fixed card height. Each
          // row is individually tappable (no separate CTA); rows are wrapped
          // in their own Expanded + scrollview so a future entry with more
          // venues than fit scrolls internally instead of overflowing the
          // card's fixed height.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // Fill the viewport when the venues are few (spreading them
                    // instead of leaving the card's lower half blank), and
                    // still scroll if an entry ever carries more than fits.
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(venues.length, (idx) {
                          final v = venues[idx];
                          final slots = (v['slots'] as List).cast<String>();
                          return GestureDetector(
                            // Opaque so the whole row responds — including the
                            // gap beside a short venue name and the strip
                            // above the divider.
                            behavior: HitTestBehavior.opaque,
                            onTap: () => openVenue(v),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      // Venue info row
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              v['image'] as String,
                              // Sized up with the slot pills so the two venue
                              // rows carry the card's height rather than
                              // floating in it.
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 58,
                                height: 58,
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
                                    fontSize: Responsive.sp(context, 15),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      v['location'] as String,
                                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: AppColors.textSecondary),
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
                      const SizedBox(height: 12),
                      // Time slot pills — evenly spaced across the width
                      Row(
                        children: List.generate(slots.length, (s) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: s < slots.length - 1 ? 10 : 0),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE8E8E8)),
                                ),
                                child: Text(
                                  slots[s],
                                  style: GoogleFonts.poppins(
                                    fontSize: Responsive.sp(context, 12),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                              if (idx < venues.length - 1) ...[
                                const SizedBox(height: 18),
                                Divider(color: Colors.grey.shade200, height: 1),
                              ],
                            ],
                          ),
                          );
                        }),
                      ),
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
    );

    // This card lists two venues, so the row taps above stay authoritative —
    // an inner detector wins the gesture arena over an outer one. This wrapper
    // only catches what's left (the sport header, the padding), routing it to
    // the first venue so no part of the card is inert.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: venues.isEmpty ? null : () => openVenue(venues.first),
      child: card,
    );
  }

  // ── Hand-On Space card (image-dominant) ──
  Widget _buildHandsOnCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.82, max: 350),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image fills the extra card height so the gap below the content
            // is always exactly the content's 20px bottom padding.
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(event.imagePath, width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Easy on the pocket card (image + full-width distance band) ──
  Widget _buildEasyPocketCard(BuildContext context, EventModel event, int index) {
    const bandColors = [Color(0xFF6B9B37), Color(0xFFE8821E), Color(0xFF3E8E7E)];
    final bandColor = bandColors[index % bandColors.length];
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.55, max: 235),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image fills the card edge-to-edge (top + sides); only the
            // top corners are rounded to match the card shape.
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Column(
                children: [
                  Image.asset(event.imagePath, height: Responsive.h(context, 186, min: 172), width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: Responsive.h(context, 186, min: 172), color: Colors.grey.shade200)),
                  // Full-width distance band — flush against the image.
                  if ((event.tag ?? '').isNotEmpty)
                    Container(
                      width: double.infinity,
                      color: bandColor,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      alignment: Alignment.center,
                      child: Text(event.tag!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: Colors.white, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Headed to the Mall card (overlapping pills + age + rating + Visit) ──
  Widget _buildMallCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.82, max: 340),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image fills the extra card height (tag pills inside bottom-left).
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.asset(event.imagePath, width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200)),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Row(children: [
                      if ((event.tag ?? '').isNotEmpty)
                        _bigDayPill(event.tag!, const Color(0xFFDB2777), Colors.white),
                      if ((event.tag ?? '').isNotEmpty) const SizedBox(width: 8),
                      _bigDayPill('Premium', const Color(0xFFFFC107), AppColors.textPrimary),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(children: [
                      Expanded(child: Text(event.title, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      if (event.description != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.people_outline, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(event.description!, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12), color: AppColors.textSecondary)),
                      ],
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  // ── Your Way, Your Plan tiles ──
  static const List<Map<String, dynamic>> _yourWayTiles = [
    {'label': 'Hourly Slots',         'image': 'resources- tlb-ui/venues_page/yourway/hourly.png',  'bg': Color(0xFFFDECD6), 'light': true},
    {'label': 'Day Passes &\nTickets','image': 'resources- tlb-ui/venues_page/yourway/tickets.png', 'bg': Color(0xFFCCEDE8), 'light': true},
    {'label': 'Private Rentals',      'image': 'resources- tlb-ui/venues_page/yourway/private.png', 'bg': Color(0xFF2F6BFF), 'light': false},
    {'label': 'Eat & Play\nCafes',    'image': 'resources- tlb-ui/venues_page/yourway/eat.png',     'bg': Color(0xFFFDECD6), 'light': true},
    {'label': 'Guided Tours',         'image': 'resources- tlb-ui/venues_page/yourway/guided.png',  'bg': Color(0xFF2F6BFF), 'light': false},
    {'label': 'DIY & Creative\nHubs', 'image': 'resources- tlb-ui/venues_page/yourway/DIY.png',     'bg': Color(0xFFEC4899), 'light': false},
    {'label': 'Retreat',              'image': 'resources- tlb-ui/venues_page/yourway/retreat.png', 'bg': Color(0xFFFBE3D0), 'light': true},
  ];

  Widget _buildYourWayRow(BuildContext context) {
    return SizedBox(
      height: 130,
      child: AutoScrollList(
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
    final textColor = lightText ? AppColors.textPrimary : Colors.white;
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
              style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 11), fontWeight: FontWeight.w500, color: textColor),
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

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VenueDetailScreen(event: event))),
      child: Container(
        width: Responsive.cardWidth(context, fraction: 0.78, max: 320),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.7),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          // Inner padding so the image floats inside the card with rounded
          // boundaries on all sides (per reference).
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image banner — shown whole, rounded on all corners ──
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          event.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    // Shining star badge — top left
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: ShiningStarBadge(size: 38),
                    ),
                    // Tag pills — bottom left ("Low noise", "Safe Space")
                    if (tags.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEC4899),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 10.5), fontWeight: FontWeight.w500, color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── Title ──
              Text(
                event.title,
                style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 16), fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // ── Location ──
              Row(children: [
                Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(child: Text(event.venue, style: GoogleFonts.poppins(fontSize: Responsive.sp(context, 12.5), color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

}
