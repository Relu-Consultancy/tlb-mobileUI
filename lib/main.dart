import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'core/app_theme.dart';
import 'core/firebase_bootstrap.dart';
import 'core/preview_mode.dart';
import 'providers/auth_state.dart';
import 'providers/follow_state.dart';
import 'providers/saved_events_state.dart';
import 'services/avatar_storage.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/login_sheet.dart';
import 'widgets/preview_toggle_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tolerate startup-time init failures here — the Google sign-in screens
  // retry [FirebaseBootstrap.ensureInitialized] before touching FirebaseAuth
  // and will surface the real error to the user if it still fails there.
  try {
    await FirebaseBootstrap.ensureInitialized();
  } catch (_) {
    /* swallowed — retried on-demand in Google sign-in flows */
  }
  await PreviewMode.load();
  // Local profile picture survives across launches even though backend
  // profile API has no avatar field yet.
  final localAvatar = await AvatarStorage.load();
  if (localAvatar != null) AuthState.avatarUrl.value = localAvatar;
  final restored = await AuthState.tryRestoreSession();
  if (restored) {
    SavedEventsState.loadFromApi(); // fire-and-forget
    final uid = AuthState.userId;
    if (uid != null) FollowState.loadForUser(uid); // fire-and-forget
  }
  // Request highest refresh rate (90Hz / 120Hz depending on device)
  await FlutterDisplayMode.setHighRefreshRate();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // Disable runtime font fetching — use bundled fonts only
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(TLBRoot(isLoggedIn: restored));
}

class TLBRoot extends StatelessWidget {
  /// True when [AuthState.tryRestoreSession] succeeded at startup. Used to
  /// decide whether the splash routes to the dashboard or the login screen.
  final bool isLoggedIn;

  const TLBRoot({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dev tools (DevicePreview wrapper + floating toggle button) only
          // mount in *debug* mode. Profile and release builds skip them
          // entirely so end users never see the developer chrome.
          if (kDebugMode)
            ValueListenableBuilder<bool>(
              valueListenable: PreviewMode.enabled,
              builder: (_, isEnabled, __) {
                return DevicePreview(
                  enabled: isEnabled,
                  builder: (_) => TLBApp(isLoggedIn: isLoggedIn),
                );
              },
            )
          else
            TLBApp(isLoggedIn: isLoggedIn),
          if (kDebugMode) const PreviewToggleButton(),
        ],
      ),
    );
  }
}

class TLBApp extends StatelessWidget {
  final bool isLoggedIn;

  const TLBApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // First launch with no saved session → land on the login screen after the
    // splash. Existing users with a restored session keep their previous
    // behaviour and go straight to the dashboard.
    final Widget nextScreen =
        isLoggedIn ? const HomeScreen() : const LoginScreen();

    return MaterialApp(
      title: 'TLB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // DevicePreview.locale / appBuilder require the DevicePreview ancestor
      // — which is only present in debug builds — so skip them in profile
      // and release.
      locale: kDebugMode ? DevicePreview.locale(context) : null,
      // Clamp OS text-scaling to 1.0 so system "Large Text" settings
      // cannot overflow fixed-height layouts across all 44 screens.
      builder: (context, child) {
        final clamped = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
        return kDebugMode
            ? DevicePreview.appBuilder(context, clamped)
            : clamped;
      },
      home: SplashScreen(nextScreen: nextScreen),
    );
  }
}
