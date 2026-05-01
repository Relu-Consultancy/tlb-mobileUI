import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/providers/saved_events_state.dart';
import 'package:tlb_mobile_ui/widgets/wishlist_button.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: 'e3',
    title: 'Testing Event',
    venue: 'Test Venue',
    imagePath: 'assets/images/placeholder.png',
  );

  setUp(() {
    AuthState.isLoggedIn.value = false;
    SavedEventsState.savedEvents.value = [];
  });

  group('WishlistButton Tests', () {
    testWidgets('renders unliked heart icon initially', (WidgetTester tester) async {
      await pumpTLBApp(tester, const Scaffold(body: WishlistButton(event: testEvent)));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('toggles state when logged in', (WidgetTester tester) async {
      AuthState.isLoggedIn.value = true;
      await pumpTLBApp(tester, const Scaffold(body: WishlistButton(event: testEvent)));

      // Tap to like
      await tester.tap(find.byType(WishlistButton));
      await tester.pumpAndSettle(); // Allow animation to complete

      // Should show filled heart and add to state
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(SavedEventsState.savedEvents.value.contains(testEvent), isTrue);

      // Tap to unlike
      await tester.tap(find.byType(WishlistButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(SavedEventsState.savedEvents.value.contains(testEvent), isFalse);
    });

    testWidgets('shows login sheet when tapped while logged out', (WidgetTester tester) async {
      AuthState.isLoggedIn.value = false;
      await pumpTLBApp(tester, const Scaffold(body: WishlistButton(event: testEvent)));

      await tester.tap(find.byType(WishlistButton));
      await tester.pumpAndSettle();

      // Ensure event is not saved
      expect(SavedEventsState.savedEvents.value.contains(testEvent), isFalse);

      // Verify the Login Sheet opened by looking for common text in it
      expect(find.text('Login to explore amazing kids events!'), findsOneWidget); // Found in login_sheet.dart
    });
  });
}
