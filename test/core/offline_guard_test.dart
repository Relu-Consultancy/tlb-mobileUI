import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/core/offline_guard.dart';
import 'package:tlb_mobile_ui/providers/connectivity_state.dart';
import 'package:tlb_mobile_ui/screens/network_error_screen.dart';
import 'package:tlb_mobile_ui/screens/splash_screen.dart';

void main() {
  late GlobalKey<NavigatorState> navKey;

  setUp(() {
    navKey = GlobalKey<NavigatorState>();
    ConnectivityState.resetForTest();
    NetworkErrorScreen.resetForTest();
    OfflineGuard.resetForTest();
    OfflineGuard.confirmAfter = const Duration(milliseconds: 100);
    SplashScreen.handedOff.value = true;
    ConnectivityState.isOnline.value = true;
  });

  tearDown(() {
    OfflineGuard.resetForTest();
    ConnectivityState.resetForTest();
    SplashScreen.handedOff.value = false;
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: Text('Some screen')),
    ));
    OfflineGuard.start(navKey);
  }

  Future<void> goOffline(WidgetTester tester) async {
    ConnectivityState.probe = () async => false;
    ConnectivityState.isOnline.value = false;
    await tester.pump(OfflineGuard.confirmAfter);
    await tester.pumpAndSettle();
  }

  // The screen re-checks on a timer; take it down so none outlives the test.
  Future<void> teardownScreen(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  testWidgets('TC_C_OG_001 — losing the connection covers the open screen',
      (tester) async {
    await pumpApp(tester);
    await goOffline(tester);

    expect(find.text('No internet connection'), findsOneWidget);
    await teardownScreen(tester);
  });

  testWidgets('TC_C_OG_002 — it lifts by itself when the connection returns',
      (tester) async {
    await pumpApp(tester);
    await goOffline(tester);

    ConnectivityState.probe = () async => true;
    ConnectivityState.isOnline.value = true;
    await tester.pumpAndSettle();
    expect(find.text('No internet connection'), findsNothing);
    expect(find.text('Some screen'), findsOneWidget);
  });

  testWidgets('TC_C_OG_003 — a momentary blip does not show it',
      (tester) async {
    await pumpApp(tester);
    // One failed probe, but the confirming re-check succeeds.
    ConnectivityState.probe = () async => true;
    ConnectivityState.isOnline.value = false;
    await tester.pump(OfflineGuard.confirmAfter);
    await tester.pumpAndSettle();

    expect(find.text('No internet connection'), findsNothing);
  });

  testWidgets('TC_C_OG_004 — waits for the splash to hand over',
      (tester) async {
    SplashScreen.handedOff.value = false;
    await pumpApp(tester);
    await goOffline(tester);
    expect(find.text('No internet connection'), findsNothing);

    SplashScreen.handedOff.value = true;
    await tester.pump(OfflineGuard.confirmAfter);
    await tester.pumpAndSettle();
    expect(find.text('No internet connection'), findsOneWidget);
    await teardownScreen(tester);
  });

  testWidgets('TC_C_OG_005 — a flicker straight back offline shows it again',
      (tester) async {
    await pumpApp(tester);
    await goOffline(tester);

    // Back for an instant, then gone again before the guard has finished.
    ConnectivityState.isOnline.value = true;
    ConnectivityState.isOnline.value = false;
    await tester.pumpAndSettle();
    await tester.pump(OfflineGuard.confirmAfter);
    await tester.pumpAndSettle();
    // Exactly one copy, over the screen.
    expect(find.text('No internet connection'), findsOneWidget);
    await teardownScreen(tester);
  });

  testWidgets('TC_C_OG_006 — a drop while it is up adds no second copy',
      (tester) async {
    await pumpApp(tester);
    await goOffline(tester);

    final again = await NetworkErrorScreen.showWith(navKey.currentState!);
    await tester.pumpAndSettle();
    expect(again, isFalse);
    expect(find.text('No internet connection'), findsOneWidget);
    await teardownScreen(tester);
  });
}
