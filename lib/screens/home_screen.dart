import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../providers/location_state.dart';
import '../sections/home_header.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/categories_grid.dart';
import '../widgets/section_divider_widget.dart';
import '../widgets/empty_location_widget.dart';
import '../sections/hot_picks_section.dart';
import '../sections/weekend_special_section.dart';
import '../sections/tlb_signature_section.dart';
import '../sections/special_needs_section.dart';
import '../sections/stealers_section.dart';
import '../sections/discover_near_you_section.dart';
import '../sections/family_feels_section.dart';
import '../sections/new_on_the_block_section.dart';
import '../sections/parents_favorite_section.dart';
import '../sections/app_footer.dart';
import '../widgets/floating_navbar.dart';
import '../helpers/walkthrough_keys.dart';
import '../services/walkthrough_service.dart';
import '../widgets/walkthrough_intro_overlay.dart';
import 'events_screen.dart';
import 'classes_screen.dart';
import 'programs_screen.dart';
import 'venues_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _shouldShowIntro = false;

  @override
  void initState() {
    super.initState();
    // Defensive — register can throw if a stale registration from a
    // previous HomeScreen still owns the singleton (happens during
    // pushAndRemoveUntil when the new HomeScreen's initState fires before
    // the old HomeScreen's dispose).
    try {
      ShowcaseView.register();
    } catch (_) {}
    _checkAndStartWalkthrough();
  }

  @override
  void dispose() {
    // Same defensive guard. get() resolves to the *current* singleton,
    // which during a HomeScreen replacement may already be the NEW one;
    // .unregister() there would either unregister the wrong instance or
    // throw and crash the dispose path.
    try {
      ShowcaseView.get().unregister();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _checkAndStartWalkthrough() async {
    final isNew = await WalkthroughService.isNewUser();
    if (!isNew || !mounted) return;
    await WalkthroughService.markWalkthroughComplete();
    setState(() => _shouldShowIntro = true);
  }

  Future<void> _launchWalkthrough() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (ctx, _, __) => WalkthroughIntroOverlay(
        onNext: () => Navigator.of(ctx).pop(),
      ),
    );
    if (!mounted) return;
    ShowcaseView.get().startShowCase(WalkthroughKeys.orderedKeys);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheImages();
  }

  void _precacheImages() {
    for (final event in DummyData.bannerEvents) {
      precacheImage(AssetImage(event.imagePath), context);
    }
  }

  int _currentNavIndex = 0;

  void _onNavTapped(int index) {
    if (index == _currentNavIndex) return;
    
    // Only handling Home -> Events routing for now.
    if (index == 1) { // Events
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EventsScreen(),
        ),
      );
    } else if (index == 2) { // Classes
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClassesScreen(),
        ),
      );
    } else if (index == 3) { // Program
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProgramsScreen(),
        ),
      );
    } else if (index == 4) { // Venues
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VenuesScreen(),
        ),
      );
    } else {
      setState(() {
        _currentNavIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    if (_shouldShowIntro) {
      _shouldShowIntro = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _launchWalkthrough();
      });
    }

    // Extra bottom space so the last section isn't hidden behind the
    // floating navbar (which is overlaid via Positioned).
    final double navOverlap =
        (safeBottom > 0 ? safeBottom + 15.0 : 30.0) + 64.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Single scroll view — the gradient header scrolls together with
          // the rest of the page so the whole screen feels like one
          // continuous surface (Session-48 fix for the "partial scroll" bug).
          ValueListenableBuilder<String>(
            valueListenable: LocationState().selectedCity,
            builder: (context, city, _) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Unified header on a gradient background ──
                    // Gradient extends past the search bar through the
                    // Spotlight divider so the warm tone blends seamlessly
                    // into the purple Spotlight banner that follows.
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFD893), // vibrant warm yellow at top
                            Color(0xFFFFE3AE),
                            Color(0xFFFFEDC4),
                            Color(0xFFFFF1D2), // hold the warm cream through
                            // the Spotlight divider so the cloud image fades
                            // into a continuously-warm band, not a white one.
                            Colors.white, // fade to scaffold white at the end
                          ],
                          stops: [0.0, 0.30, 0.55, 0.88, 1.0],
                        ),
                      ),
                      child: Column(
                        children: [
                          HomeHeader(
                            profileShowcaseConfig: kProfileShowcaseConfig,
                            locationShowcaseConfig: kLocationShowcaseConfig,
                          ),
                          if (LocationState().isLocationSupported(city)) ...[
                            // Small breathing room below the search bar; the
                            // divider's own vertical padding does most of it.
                            const SizedBox(height: 4),
                            const SectionDividerWidget(
                              title: 'Spotlight',
                              lineLength: 100,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              textColor: Color(0xFF3A3A3A), // dark charcoal
                              lineThickness: 1.5,
                              lineColor: Color(0xFFD4A537), // warm gold
                            ),
                            // Keep the header close to the Spotlight banner;
                            // still extend the warm gradient slightly past the
                            // divider so the fade to scaffold-white happens
                            // *inside* the gradient container, not as a cut.
                            const SizedBox(height: 6),
                          ],
                        ],
                      ),
                    ),

                    // ── Body: empty state OR full feed ──
                    if (!LocationState().isLocationSupported(city))
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const EmptyLocationWidget(),
                      )
                    else ...[
                      RepaintBoundary(
                        child: BannerCarousel(
                          events: DummyData.bannerEvents,
                          height: Responsive.h(context, 470.0),
                          fixedCardWidth: Responsive.w(context, 345.0),
                        ),
                      ),
                      const RepaintBoundary(child: CategoriesGrid()),

                      // Sections
                      const RepaintBoundary(child: HotPicksSection()),
                      const RepaintBoundary(child: WeekendSpecialSection()),
                      const RepaintBoundary(child: DiscoverNearYouSection()),
                      const RepaintBoundary(child: FamilyFeelsSection()),
                      const RepaintBoundary(child: NewOnTheBlockSection()),
                      const RepaintBoundary(child: ParentsFavoriteSection()),
                      const RepaintBoundary(child: StealersSection()),
                      // "Where Every Star Shines" (renamed Special Needs)
                      const RepaintBoundary(child: SpecialNeedsSection()),
                      const RepaintBoundary(child: TlbSignatureSection()),

                      // AppFooter with upward gradient
                      const AppFooter(),
                    ],

                    // Spacer so the last item clears the floating navbar.
                    SizedBox(height: navOverlap),
                  ],
                ),
              );
            },
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
                showcaseConfigs: kNavShowcaseConfigs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
