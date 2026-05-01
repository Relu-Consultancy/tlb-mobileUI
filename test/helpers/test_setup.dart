import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/core/app_theme.dart';

/// Helper to wrap widgets with a MaterialApp
Future<void> pumpTLBApp(WidgetTester tester, Widget child) async {
  // Mock secure storage for all tests
  FlutterSecureStorage.setMockInitialValues({});
  // Ignore RenderFlex overflow errors in tests
  final originalOnError = FlutterError.onError!;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    originalOnError(details);
  };

  // Set a standard mobile screen size
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      title: 'TLB Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}
