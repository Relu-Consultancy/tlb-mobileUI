import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/app_theme.dart';
import 'core/preview_mode.dart';
import 'providers/auth_state.dart';
import 'providers/follow_state.dart';
import 'providers/saved_events_state.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/preview_toggle_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  await PreviewMode.load();
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
  runApp(const TLBRoot());
}

class TLBRoot extends StatelessWidget {
  const TLBRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: PreviewMode.enabled,
            builder: (_, isEnabled, __) {
              return DevicePreview(
                enabled: isEnabled,
                builder: (_) => const TLBApp(),
              );
            },
          ),
          const PreviewToggleButton(),
        ],
      ),
    );
  }
}

class TLBApp extends StatelessWidget {
  const TLBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: DevicePreview.locale(context),
      // Clamp OS text-scaling to 1.0 so system "Large Text" settings
      // cannot overflow fixed-height layouts across all 44 screens.
      builder: (context, child) {
        final clamped = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
        return DevicePreview.appBuilder(context, clamped);
      },
      home: const SplashScreen(nextScreen: HomeScreen()),
    );
  }
}
