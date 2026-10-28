import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/widgets/subcategory_empty_state.dart';

import '../helpers/test_setup.dart';

void main() {
  group('SubcategoryEmptyState Tests', () {
    testWidgets('TC_ES_001 — renders Coming Soon title', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        expect(find.text('Coming Soon!'), findsOneWidget);
      });
    });

    testWidgets('TC_ES_002 — renders Notify Me button', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        expect(find.text('Notify Me'), findsOneWidget);
      });
    });

    testWidgets('TC_ES_003 — renders Explore Other Categories link', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        expect(find.text('Explore Other Categories'), findsOneWidget);
      });
    });

    testWidgets('TC_ES_004 — Notify Me shows snackbar on tap', (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        await tester.tap(find.text('Notify Me'));
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    testWidgets('TC_ES_005 — custom onExploreOtherCategories callback fires', (tester) async {
      bool tapped = false;
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: SubcategoryEmptyState(
              onExploreOtherCategories: () => tapped = true,
            ),
          ),
        );
        await tester.tap(find.text('Explore Other Categories'));
        expect(tapped, isTrue);
      });
    });

    testWidgets('TC_ES_006 — default callback pops route when no callback supplied',
        (tester) async {
      await mockNetworkImages(() async {
        // Push a second route with the empty state so we can pop back
        late NavigatorState nav;
        await pumpTLBApp(
          tester,
          Builder(builder: (context) {
            nav = Navigator.of(context);
            return TextButton(
              onPressed: () => nav.push(
                MaterialPageRoute(builder: (_) => const Scaffold(body: SubcategoryEmptyState())),
              ),
              child: const Text('Go'),
            );
          }),
        );
        await tester.tap(find.text('Go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Explore Other Categories'));
        await tester.pumpAndSettle();
        // After pop, first screen should be visible again
        expect(find.text('Go'), findsOneWidget);
      });
    });

    testWidgets('TC_ES_007 — no overflow on narrow screen', (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('TC_ES_008 — renders on large tablet-size screen', (tester) async {
      tester.view.physicalSize = const Size(2048, 2732);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const Scaffold(body: SubcategoryEmptyState()));
        expect(tester.takeException(), isNull);
      });
    });
  });
}
