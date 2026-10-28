import 'package:flutter/material.dart';

class WalkthroughKeys {
  WalkthroughKeys._();

  // Step 1: location row in home header
  static final GlobalKey locationRow  = GlobalKey(debugLabel: 'showcase_location');
  // Step 2: Home nav tab
  static final GlobalKey navHome      = GlobalKey(debugLabel: 'showcase_nav_home');
  // Step 3: the first listing card on Home (Hot Picks) — teaches that any
  // section card opens that listing's full detail screen.
  static final GlobalKey firstSectionCard = GlobalKey(debugLabel: 'showcase_section_card');
  // Steps 4–7: remaining navbar tabs
  static final GlobalKey navEvents    = GlobalKey(debugLabel: 'showcase_nav_events');
  static final GlobalKey navClasses   = GlobalKey(debugLabel: 'showcase_nav_classes');
  static final GlobalKey navPrograms  = GlobalKey(debugLabel: 'showcase_nav_programs');
  static final GlobalKey navVenues    = GlobalKey(debugLabel: 'showcase_nav_venues');
  // Step 8: profile avatar in home header
  static final GlobalKey profileAvatar = GlobalKey(debugLabel: 'showcase_profile');

  // Full sequence (intro overlay fires before this list)
  static List<GlobalKey> get orderedKeys => [
    locationRow,
    navHome,
    firstSectionCard,
    navEvents,
    navClasses,
    navPrograms,
    navVenues,
    profileAvatar,
  ];

  static int get totalSteps => orderedKeys.length;

  // Steps resumed AFTER the location picker closes. Tapping the highlighted
  // location chip opens LocationScreen (which disposes the running showcase so
  // its dark overlay doesn't sit on top of that screen); when the user returns
  // we restart the tour from these keys so the rest of the sequence still runs.
  static List<GlobalKey> get afterLocationKeys => [
    navHome,
    firstSectionCard,
    navEvents,
    navClasses,
    navPrograms,
    navVenues,
    profileAvatar,
  ];
}

// ── Config structs ────────────────────────────────────────────────────────────
//
// `stepIndex` is each step's fixed position in WalkthroughKeys.orderedKeys
// (0-based) — the tooltip card reads it directly to render "2 / 8" and the
// progress dots, rather than the tour trying to infer position from the
// package's internal state.

class ShowcaseNavConfig {
  final GlobalKey showcaseKey;
  final IconData icon;
  final String title;
  final String description;
  final int stepIndex;
  const ShowcaseNavConfig({
    required this.showcaseKey,
    required this.icon,
    required this.title,
    required this.description,
    required this.stepIndex,
  });
}

class ShowcaseProfileConfig {
  final GlobalKey showcaseKey;
  final IconData icon;
  final String title;
  final String description;
  final int stepIndex;
  const ShowcaseProfileConfig({
    required this.showcaseKey,
    required this.icon,
    required this.title,
    required this.description,
    required this.stepIndex,
  });
}

// ── Pre-built instances passed by HomeScreen to FloatingNavbar + HomeHeader ───
// Map keys = FloatingNavbar _navItems indices (0=Home, 1=Events, 2=Classes, 3=Programs, 4=Venues)

final Map<int, ShowcaseNavConfig> kNavShowcaseConfigs = {
  0: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navHome,
    icon: Icons.home_rounded,
    title: 'Home',
    description: 'Browse curated picks & spotlight events',
    stepIndex: 1,
  ),
  1: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navEvents,
    icon: Icons.calendar_month_rounded,
    title: 'Events',
    description: 'Discover and book events near you',
    stepIndex: 3,
  ),
  2: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navClasses,
    icon: Icons.school_rounded,
    title: 'Classes',
    description: 'Explore classes for all ages',
    stepIndex: 4,
  ),
  3: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navPrograms,
    icon: Icons.route_rounded,
    title: 'Programs',
    description: 'Join structured programs',
    stepIndex: 5,
  ),
  4: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navVenues,
    icon: Icons.location_city_rounded,
    title: 'Venues',
    description: 'Find and book amazing venues',
    stepIndex: 6,
  ),
};

final kLocationShowcaseConfig = ShowcaseProfileConfig(
  showcaseKey: WalkthroughKeys.locationRow,
  icon: Icons.location_on_rounded,
  title: 'Set Your Location',
  description: 'Enable location access to discover events, classes, programs, and venues near you for a personalized experience.',
  stepIndex: 0,
);

/// Any listing card in any Home section — this one is the first card of Hot
/// Picks, used as the one concrete example the tour points at.
final kSectionCardShowcaseConfig = ShowcaseProfileConfig(
  showcaseKey: WalkthroughKeys.firstSectionCard,
  icon: Icons.touch_app_rounded,
  title: 'Tap Any Card',
  description: 'Every card across the app opens its full details — photos, pricing, timing, and instant booking.',
  stepIndex: 2,
);

final kProfileShowcaseConfig = ShowcaseProfileConfig(
  showcaseKey: WalkthroughKeys.profileAvatar,
  icon: Icons.person_rounded,
  title: 'Profile',
  description: 'Access your profile, bookings, and settings',
  stepIndex: 7,
);
