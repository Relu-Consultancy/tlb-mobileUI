# Future Work: Dark Mode

A dark mode toggle was requested (Account Settings → switch that turns white/whitish
backgrounds black across every screen). Feasibility was assessed but implementation was
deliberately deferred — this file is the reminder to pick it back up.

## Why it's deferred

The app's theming today is **hardcoded-color-driven, not theme-driven**:

- `lib/main.dart` wires a single `ThemeData` (`lib/core/app_theme.dart`) with no
  `darkTheme:` and no `ThemeMode` plumbing.
- `lib/core/app_colors.dart` is a flat class of 61 `static const Color` values —
  no brightness-awareness, referenced ~865 times across ~110 files.
- On top of that, ~1,500+ color references bypass `AppColors` entirely and are
  scattered directly in screen/widget files:
  - ~856 raw `Color(0xFF...)` hex literals outside `app_colors.dart`
  - ~445 direct `Colors.white` calls
  - ~192 direct `Colors.black` calls
  - 68 of 74 `Scaffold` widgets hardcode their own `backgroundColor:` per screen
- Even `lib/screens/account_settings_screen.dart` (where the toggle would live)
  mixes raw `Colors.white`/hex literals with `AppColors.*`.

Every one of those hardcoded references is a spot that won't respond to a dark-mode
switch unless specifically touched — the toggle UI itself is trivial, the real cost
is this scattered color debt across ~190 Dart files under `lib/`.

## What proper implementation would require

1. Turn `AppColors`'s constants into brightness-aware lookups (a `ThemeExtension`,
   or an `AppColors.of(context)` pattern) instead of static consts.
2. Build a real `darkTheme` in `AppTheme` and wire `themeMode` through `MaterialApp`,
   driven by a persisted `ValueNotifier<ThemeMode>` — `lib/core/preview_mode.dart`
   (`ValueNotifier<bool>` + `SharedPreferences`) is an existing precedent for this
   pattern in the codebase.
3. Go through all ~190 Dart files under `lib/` and replace hardcoded
   `Colors.white`/`Colors.black`/raw hex with theme-aware references — this is the
   bulk of the work, not the toggle itself.
4. Audit images/icons/shadows too — some assets (logos, illustrations) may assume
   a white background and won't automatically look right on black.
5. Add the actual `Switch` row in Account Settings (~10 lines, not the bottleneck).

## Suggested approach when picked up

Staged rollout rather than a single PR: ship the toggle + `ThemeMode` plumbing +
core screens first (Home, Account Settings), then expand dark-mode coverage
screen-by-screen rather than attempting all ~190 files at once.

Estimated scope: multi-day, high-file-count refactor — not a contained feature.
