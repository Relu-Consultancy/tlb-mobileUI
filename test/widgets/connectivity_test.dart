import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/providers/connectivity_state.dart';
import 'package:tlb_mobile_ui/screens/network_error_screen.dart';
import 'package:tlb_mobile_ui/widgets/connectivity_toast.dart';

import '../helpers/test_setup.dart';

void main() {
  tearDown(ConnectivityState.resetForTest);

  Future<void> pumpToast(WidgetTester tester) => pumpTLBApp(
        tester,
        const Scaffold(body: Stack(children: [ConnectivityToast()])),
      );

  group('ConnectivityToast', () {
    testWidgets('TC_W_CON_001 — losing the connection shows "You\'re offline"',
        (tester) async {
      ConnectivityState.isOnline.value = true;
      await pumpToast(tester);

      ConnectivityState.isOnline.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text("You're offline"), findsOneWidget);

      // Hides itself again.
      await tester.pump(ConnectivityToast.offlineFor);
      await tester.pumpAndSettle();
      final opacity = tester.widget<AnimatedOpacity>(find.ancestor(
          of: find.text("You're offline"),
          matching: find.byType(AnimatedOpacity)));
      expect(opacity.opacity, 0);
    });

    testWidgets('TC_W_CON_002 — coming back shows "Back online"',
        (tester) async {
      ConnectivityState.isOnline.value = false;
      await pumpToast(tester);

      ConnectivityState.isOnline.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Back online'), findsOneWidget);
      await tester.pump(ConnectivityToast.onlineFor);
      await tester.pumpAndSettle();
    });

    testWidgets('TC_W_CON_003 — being online at launch is not announced',
        (tester) async {
      await pumpToast(tester); // isOnline starts null
      ConnectivityState.isOnline.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final opacity = tester.widget<AnimatedOpacity>(find.descendant(
          of: find.byType(ConnectivityToast),
          matching: find.byType(AnimatedOpacity)));
      expect(opacity.opacity, 0);
    });
  });

  group('NetworkErrorScreen', () {
    setUp(NetworkErrorScreen.resetForTest);

    /// Opens the screen through [NetworkErrorScreen.show], as the app does,
    /// and records what it completes with.
    Future<List<bool>> open(WidgetTester tester) async {
      final results = <bool>[];
      await pumpTLBApp(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  results.add(await NetworkErrorScreen.show(context)),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    /// The screen re-checks on a timer; take it down so no timer outlives
    /// the test.
    Future<void> teardownScreen(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    testWidgets('TC_W_CON_004 — state-screen copy, Try Again, no back arrow',
        (tester) async {
      ConnectivityState.probe = () async => false;
      await open(tester);
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.textContaining('Check your Wi-Fi'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
      await teardownScreen(tester);
    });

    testWidgets('TC_W_CON_005 — Try Again while still offline stays put',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Still offline. Check your connection.'), findsOneWidget);
      expect(results, isEmpty);
      await teardownScreen(tester);
    });

    testWidgets('TC_W_CON_006 — Try Again once back online closes with true',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      ConnectivityState.probe = () async => true;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_007 — closes by itself when the network returns',
        (tester) async {
      ConnectivityState.probe = () async => false;
      ConnectivityState.isOnline.value = false;
      final results = await open(tester);

      ConnectivityState.isOnline.value = true;
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_008 — system back is blocked while offline',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      // Android back button / iOS back swipe.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('No internet connection. Reconnect to continue.'),
          findsOneWidget);
      expect(results, isEmpty);
      await teardownScreen(tester);
    });

    testWidgets('TC_W_CON_009 — system back once reconnected lets them through',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      ConnectivityState.probe = () async => true;
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('No internet connection'), findsNothing);
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_010 — a periodic re-check catches a silent recovery',
        (tester) async {
      // Internet back on the same Wi-Fi: no network-change event fires.
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      ConnectivityState.probe = () async => true;
      await tester.pump(NetworkErrorScreen.pollEvery);
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_011 — returning from the background re-checks',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      ConnectivityState.probe = () async => true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_012 — already online when it opens: closes at once',
        (tester) async {
      ConnectivityState.probe = () async => true;
      ConnectivityState.isOnline.value = true;
      final results = await open(tester);
      expect(find.text('No internet connection'), findsNothing);
      expect(results, [true]);
    });

    testWidgets('TC_W_CON_013 — a second open does not stack another copy',
        (tester) async {
      ConnectivityState.probe = () async => false;
      final results = await open(tester);

      // The button is still in the tree underneath; open again.
      final ctx = tester.element(find.text('open', skipOffstage: false));
      final second = await NetworkErrorScreen.show(ctx);
      await tester.pumpAndSettle();
      expect(second, isFalse);
      expect(find.text('No internet connection'), findsOneWidget);
      expect(results, isEmpty);
      await teardownScreen(tester);
    });
  });
}
