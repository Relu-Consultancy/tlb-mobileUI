import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/widgets/app_loader.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() => AppLoader.useCustomLoader = true);
  tearDown(() => AppLoader.useCustomLoader = true);

  // ─── AppLoader (full-screen) ────────────────────────────────────────────────

  group('AppLoader — full-screen', () {
    testWidgets('TC_L_001 — renders custom animated dots by default', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: AppLoader()));
      // Custom loader shows Row of dot containers, not CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_L_002 — falls back to CircularProgressIndicator when flag is false',
        (tester) async {
      AppLoader.useCustomLoader = false;
      await pumpTLBApp(tester, const Scaffold(body: AppLoader()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TC_L_003 — AppLoader.useCustomLoader toggles globally', (tester) async {
      expect(AppLoader.useCustomLoader, isTrue);
      AppLoader.useCustomLoader = false;
      expect(AppLoader.useCustomLoader, isFalse);
      AppLoader.useCustomLoader = true;
      expect(AppLoader.useCustomLoader, isTrue);
    });

    testWidgets('TC_L_004 — centres content on screen', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: AppLoader()));
      expect(find.byType(Center), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_L_005 — does not throw on rapid pump/settle', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: AppLoader()));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });
  });

  // ─── AppLoaderInline (button/compact) ──────────────────────────────────────

  group('AppLoaderInline — inline/button', () {
    testWidgets('TC_L_006 — renders inline without overflow', (tester) async {
      await pumpTLBApp(
        tester,
        Scaffold(
          body: ElevatedButton(
            onPressed: null,
            child: const AppLoaderInline(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_L_007 — falls back to CircularProgressIndicator when flag is false',
        (tester) async {
      AppLoader.useCustomLoader = false;
      await pumpTLBApp(tester, const Scaffold(body: AppLoaderInline()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TC_L_008 — renders custom dots when flag is true', (tester) async {
      await pumpTLBApp(tester, const Scaffold(body: AppLoaderInline()));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TC_L_009 — inline loader is compact (no full-screen expansion)',
        (tester) async {
      await pumpTLBApp(
        tester,
        const Scaffold(
          body: SizedBox(width: 100, height: 40, child: AppLoaderInline()),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
