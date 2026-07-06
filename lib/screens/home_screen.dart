import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../data/dummy_data.dart';
import '../providers/location_state.dart';
import '../providers/saved_events_state.dart';
import '../providers/notifications_state.dart';
import '../services/push_notifications.dart';
// import '../providers/home_feed_state.dart'; // commented out — home reverted to mock data
import '../sections/home_header.dart';
import '../sections/spotlight_stage.dart';
import '../widgets/categories_grid.dart';
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
import '../widgets/app_refresh_indicator.dart';
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
    // Pull the unread notification count so the header bell badge is accurate
    // as soon as the home screen appears (after login / session restore).
    NotificationsState.refreshFromApi();
    // Mirror any new in-app notifications to the system tray, and make sure
    // this device's push token is registered with the backend (covers the
    // fresh-login path — main() only does this on a restored session).
    NotificationsState.syncAndNotify();
    PushNotifications.registerToken();
    // Load the real homepage feed (sections + hydrated cards). Sections render
    // reactively once this completes; empty sections hide themselves.
    // Commented out for now — home sections reverted to mock data.
    // HomeFeedState.load();
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

  // Pull-to-refresh: reload live wishlist/saved state and rebuild the feed.
  Future<void> _handleRefresh() async {
    await Future.wait([
      SavedEventsState.loadFromApi(),
      // HomeFeedState.load(force: true), // commented out — sections use mock data
    ]);
    if (mounted) setState(() {});
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
    if (_shouldShowIntro) {
      _shouldShowIntro = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _launchWalkthrough();
      });
    }

    // Extra bottom space so the last section isn't hidden behind the
    // floating navbar (which is overlaid via Positioned).
    final double navOverlap = FloatingNavbar.clearance(context);

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
              return AppRefreshIndicator(
                onRefresh: _handleRefresh,
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Unified header on a black theatrical backdrop ──
                    // Solid black behind the greeting + search bar; the golden
                    // cloud texture (screen-blended in HomeHeader) reads as a
                    // warm glow at the top and fades into the black.
                    Container(
                      decoration: const BoxDecoration(color: Colors.black),
                      child: Column(
                        children: [
                          HomeHeader(
                            onDark: true,
                            profileShowcaseConfig: kProfileShowcaseConfig,
                            locationShowcaseConfig: kLocationShowcaseConfig,
                          ),
                          // Spotlight divider — reverted to always-shown (mock).
                          // API version (hide when spotlight section empty)
                          // commented out for now:
                          /*
                          if (LocationState().isLocationSupported(city))
                            ValueListenableBuilder<int>(
                              valueListenable: HomeFeedState.version,
                              builder: (context, _, __) {
                                if (HomeFeedState.section('spotlight').isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  children: const [
                                    SizedBox(height: 4),
                                    SectionDividerWidget(
                                      title: 'Spotlight',
                                      lineLength: 100,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      textColor: Color(0xFF3A3A3A),
                                      lineThickness: 1.5,
                                      lineColor: Color(0xFFD4A537),
                                      topPadding: 6,
                                    ),
                                    SizedBox(height: 6),
                                  ],
                                );
                              },
                            ),
                          */
                          // Spotlight title now lives inside SpotlightStage
                          // (the redesigned theatrical stage section below).
                        ],
                      ),
                    ),

                    // ── Body: empty state OR full feed ──
                    if (!LocationState().isLocationSupported(city))
                      SizedBox(
                        // Fill the viewport beneath the header so the empty
                        // state centres in the space that's left (no dead white
                        // strip below it) and its CTA clears the floating
                        // navbar. ~150 ≈ the greeting + search header height
                        // above this point.
                        height: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                150)
                            .clamp(380.0, double.infinity)
                            .toDouble(),
                        child: const EmptyLocationWidget(),
                      )
                    else ...[
                      // Spotlight banner — reverted to mock data.
                      // API version (real 'spotlight' section) commented out:
                      /*
                      RepaintBoundary(
                        child: ValueListenableBuilder<int>(
                          valueListenable: HomeFeedState.version,
                          builder: (context, _, __) {
                            return BannerCarousel(
                              events: HomeFeedState.section('spotlight'),
                              height: Responsive.h(context, 480.0),
                              fixedCardWidth: Responsive.w(context, 345.0),
                            );
                          },
                        ),
                      ),
                      */
                      // ── Redesigned theatrical Spotlight stage ──
                      RepaintBoundary(
                        child: SpotlightStage(events: DummyData.bannerEvents),
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

                      // AppFooter — the full black starry footer (quote, logo,
                      // links) stretched past the floating navbar (bottomExtra)
                      // so there's no gap at the screen bottom.
                      AppFooter(bottomExtra: navOverlap),
                    ],
                  ],
                ),
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
                bottomPadding: FloatingNavbar.bottomInset(context),
                showcaseConfigs: kNavShowcaseConfigs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
