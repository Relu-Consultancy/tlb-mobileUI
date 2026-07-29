import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../data/dummy_data.dart';
import '../providers/location_state.dart';
import '../providers/saved_events_state.dart';
import '../providers/notifications_state.dart';
import '../services/push_notifications.dart';
// import '../providers/home_feed_state.dart'; // commented out — home reverted to mock data
import '../widgets/dark_glow_header.dart';
import '../widgets/spotlight_banner.dart';
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

  final ScrollController _scrollController = ScrollController();
  // 0 = floating navbar fully hidden (top of page), 1 = fully revealed. Driven
  // by scroll offset so the navbar fades + slides into view once the reader
  // scrolls past the hero (Explore the Stage scrolling away).
  final ValueNotifier<double> _navReveal = ValueNotifier<double>(0.0);

  // Navbar begins revealing after this much scroll and is fully in by the end.
  static const double _navFadeStart = 120;
  static const double _navFadeEnd = 280;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _navReveal.dispose();
    // Same defensive guard. get() resolves to the *current* singleton,
    // which during a HomeScreen replacement may already be the NEW one;
    // .unregister() there would either unregister the wrong instance or
    // throw and crash the dispose path.
    try {
      ShowcaseView.get().unregister();
    } catch (_) {}
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final double t = ((offset - _navFadeStart) / (_navFadeEnd - _navFadeStart))
        .clamp(0.0, 1.0);
    if (_navReveal.value != t) _navReveal.value = t;
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
    // Reveal the floating navbar for the onboarding tour (it starts hidden at
    // the top of the page, but the walkthrough highlights the nav tabs).
    _navReveal.value = 1.0;
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

  /// The dark Home header — TLB logo + greeting + search on a black backdrop
  /// with a warm golden radiance glowing from the top (behind the logo / status
  /// bar) and fading into the black toward the search bar.
  Widget _darkHeader() {
    return DarkGlowHeader(
      profileShowcaseConfig: kProfileShowcaseConfig,
      locationShowcaseConfig: kLocationShowcaseConfig,
    );
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
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Body: empty state OR one-viewport hero + feed ──
                    if (!LocationState().isLocationSupported(city)) ...[
                      _darkHeader(),
                      SizedBox(
                        // Fill the viewport beneath the header so the empty
                        // state centres in the space that's left.
                        height: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                150)
                            .clamp(380.0, double.infinity)
                            .toDouble(),
                        child: const EmptyLocationWidget(),
                      ),
                    ] else ...[
                      // Black hero: header + a tall Spotlight card + Explore the
                      // Stage. The floating navbar is hidden here (revealed on
                      // scroll), so the hero owns the whole first screen.
                      ColoredBox(
                        color: Colors.black,
                        child: Column(
                          children: [
                            _darkHeader(),
                            RepaintBoundary(
                              child: SizedBox(
                                height:
                                    (MediaQuery.of(context).size.height * 0.62)
                                        .clamp(420.0, 660.0),
                                child: SpotlightBanner(
                                  events: DummyData.bannerEvents,
                                ),
                              ),
                            ),
                            const RepaintBoundary(child: CategoriesGrid()),
                          ],
                        ),
                      ),

                      // The black hero ends cleanly here — the white feed below
                      // starts directly, with no grey black→white blend.

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
            // Hidden at the top of the page; fades + slides up into view as the
            // reader scrolls past the hero (Explore the Stage scrolling away).
            child: ValueListenableBuilder<double>(
              valueListenable: _navReveal,
              builder: (context, t, child) {
                return IgnorePointer(
                  ignoring: t < 0.05,
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 60),
                      child: child,
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
                  showcaseConfigs: kNavShowcaseConfigs,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
