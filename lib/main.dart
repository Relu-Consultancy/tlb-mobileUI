import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/app_theme.dart';
import 'providers/auth_state.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
  await AuthState.tryRestoreSession();
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
  runApp(const TLBApp());
}

class TLBApp extends StatelessWidget {
  const TLBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Clamp OS text-scaling to 1.0 so system "Large Text" settings
      // cannot overflow fixed-height layouts across all 44 screens.
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(nextScreen: HomeScreen()),
    );
  }
}
