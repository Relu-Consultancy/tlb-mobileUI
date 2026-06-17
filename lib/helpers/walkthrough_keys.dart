import 'package:flutter/material.dart';

class WalkthroughKeys {
  WalkthroughKeys._();

  // Step 1: location row in home header
  static final GlobalKey locationRow  = GlobalKey(debugLabel: 'showcase_location');
  // Steps 2–6: navbar tabs
  static final GlobalKey navHome      = GlobalKey(debugLabel: 'showcase_nav_home');
  static final GlobalKey navEvents    = GlobalKey(debugLabel: 'showcase_nav_events');
  static final GlobalKey navClasses   = GlobalKey(debugLabel: 'showcase_nav_classes');
  static final GlobalKey navPrograms  = GlobalKey(debugLabel: 'showcase_nav_programs');
  static final GlobalKey navVenues    = GlobalKey(debugLabel: 'showcase_nav_venues');
  // Step 7: profile avatar in home header
  static final GlobalKey profileAvatar = GlobalKey(debugLabel: 'showcase_profile');

  // Full sequence (intro overlay fires before this list)
  static List<GlobalKey> get orderedKeys => [
    locationRow,
    navHome,
    navEvents,
    navClasses,
    navPrograms,
    navVenues,
    profileAvatar,
  ];

  // Steps resumed AFTER the location picker closes. Tapping the highlighted
  // location chip opens LocationScreen (which disposes the running showcase so
  // its dark overlay doesn't sit on top of that screen); when the user returns
  // we restart the tour from these keys so the navbar tabs and profile avatar
  // are still shown.
  static List<GlobalKey> get afterLocationKeys => [
    navHome,
    navEvents,
    navClasses,
    navPrograms,
    navVenues,
    profileAvatar,
  ];
}

// ── Config structs ────────────────────────────────────────────────────────────

class ShowcaseNavConfig {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  const ShowcaseNavConfig({
    required this.showcaseKey,
    required this.title,
    required this.description,
  });
}

class ShowcaseProfileConfig {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  const ShowcaseProfileConfig({
    required this.showcaseKey,
    required this.title,
    required this.description,
  });
}

// ── Pre-built instances passed by HomeScreen to FloatingNavbar + HomeHeader ───
// Map keys = FloatingNavbar _navItems indices (0=Home, 1=Events, 2=Classes, 3=Programs, 4=Venues)

final Map<int, ShowcaseNavConfig> kNavShowcaseConfigs = {
  0: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navHome,
    title: 'Home',
    description: 'Browse curated picks & spotlight events',
  ),
  1: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navEvents,
    title: 'Events',
    description: 'Discover and book events near you',
  ),
  2: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navClasses,
    title: 'Classes',
    description: 'Explore classes for all ages',
  ),
  3: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navPrograms,
    title: 'Programs',
    description: 'Join structured programs',
  ),
  4: ShowcaseNavConfig(
    showcaseKey: WalkthroughKeys.navVenues,
    title: 'Venues',
    description: 'Find and book amazing venues',
  ),
};

final kLocationShowcaseConfig = ShowcaseProfileConfig(
  showcaseKey: WalkthroughKeys.locationRow,
  title: 'Set Your Location',
  description: 'Enable location access to discover events, classes, programs, and venues near you for a personalized experience.',
);

final kProfileShowcaseConfig = ShowcaseProfileConfig(
  showcaseKey: WalkthroughKeys.profileAvatar,
  title: 'Profile',
  description: 'Access your profile, bookings, and settings',
);
