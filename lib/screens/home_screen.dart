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
    ShowcaseView.register();
    _checkAndStartWalkthrough();
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Unified header + Spotlight title on one gradient background ──
              ValueListenableBuilder<String>(
                valueListenable: LocationState().selectedCity,
                builder: (context, city, _) {
                  return Container(
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
                    child: Column(
                      children: [
                        HomeHeader(
                          profileShowcaseConfig: kProfileShowcaseConfig,
                          locationShowcaseConfig: kLocationShowcaseConfig,
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Scrollable feed or Empty State
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: LocationState().selectedCity,
                  builder: (context, city, _) {
                    if (!LocationState().isLocationSupported(city)) {
                      return const EmptyLocationWidget();
                    }
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionDividerWidget(title: 'Spotlight'),
                            RepaintBoundary(
                              child: BannerCarousel(
                                events: DummyData.bannerEvents,
                                height: Responsive.h(context, 421.0),
                                fixedCardWidth: Responsive.w(context, 355.0),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Categories Grid (3x2 layout)
                            const RepaintBoundary(child: CategoriesGrid()),
                            
                            const SizedBox(height: 8),
                            
                            // Sections
                            const RepaintBoundary(child: HotPicksSection()),
                            const RepaintBoundary(child: WeekendSpecialSection()),
                            const RepaintBoundary(child: DiscoverNearYouSection()),
                            const RepaintBoundary(child: FamilyFeelsSection()),
                            
                            const RepaintBoundary(child: SpecialNeedsSection()),
                            const RepaintBoundary(child: StealersSection()),
                            const RepaintBoundary(child: TlbSignatureSection()),

                            // AppFooter with upward gradient
                            const AppFooter(),
                          ],
                        ),
                    );
                  },
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
                showcaseConfigs: kNavShowcaseConfigs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
