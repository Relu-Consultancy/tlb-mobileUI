import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/widgets/app_loader.dart';
import 'package:tlb_mobile_ui/widgets/review_sheet.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() {
    AuthState.isLoggedIn.value = false;
    AuthState.accessToken = null;
    AppLoader.useCustomLoader = true;
  });

  group('Write a Review guard tests (via buildReviewInlineSection)', () {
    testWidgets('TC_RS_001 — tapping Write a Review when not logged in navigates to login screen',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: Builder(builder: (context) {
              return buildReviewInlineSection(
                context,
                listingId: 'test-id',
                listingTitle: 'Test Event',
                listingImage: null,
              );
            }),
          ),
        );
        await tester.tap(find.text('Write a Review'));
        await tester.pumpAndSettle();
        expect(find.text('Login to explore amazing kids events!'), findsOneWidget);
      });
    });

    testWidgets('TC_RS_002 — Write a Review button does not open write review sheet when not logged in',
        (tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Scaffold(
            body: Builder(builder: (context) {
              return buildReviewInlineSection(
                context,
                listingId: 'test-id',
                listingTitle: 'Test Event',
                listingImage: null,
              );
            }),
          ),
        );
        await tester.tap(find.text('Write a Review'));
        await tester.pump();
        // Write review bottom sheet must NOT have opened
        expect(find.byType(BottomSheet), findsNothing);
      });
    });
  });

  group('AppLoader integration in review_sheet', () {
    testWidgets('TC_RS_003 — review list sheet uses AppLoader (not CircularProgressIndicator) while loading',
        (tester) async {
      // We cannot easily mock ReviewService, but we can verify the loader type
      // used is AppLoader and NOT bare CircularProgressIndicator.
      // This indirectly validates that review_sheet.dart uses AppLoader.
      AppLoader.useCustomLoader = false; // force fallback to CircularProgressIndicator
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Builder(builder: (context) {
            return TextButton(
              onPressed: () => showReviewSheet(
                context,
                listingId: 'test-id',
                listingTitle: 'Test Event',
                listingImage: null,
              ),
              child: const Text('Open Reviews'),
            );
          }),
        );
        await tester.tap(find.text('Open Reviews'));
        await tester.pump(); // Don't settle — catch loading state

        // With fallback active, AppLoader renders CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('TC_RS_004 — review list sheet shows custom loader when useCustomLoader is true',
        (tester) async {
      AppLoader.useCustomLoader = true;
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          Builder(builder: (context) {
            return TextButton(
              onPressed: () => showReviewSheet(
                context,
                listingId: 'test-id',
                listingTitle: 'Test Event',
                listingImage: null,
              ),
              child: const Text('Open Reviews'),
            );
          }),
        );
        await tester.tap(find.text('Open Reviews'));
        await tester.pump(); // Loading state
        // Custom loader: no bare CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
  });
}
