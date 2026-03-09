import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const SplashScreen(nextScreen: HomeScreen()),
    );
  }
}
