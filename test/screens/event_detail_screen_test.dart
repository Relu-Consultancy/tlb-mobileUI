import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/event_detail_screen.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  // id: '' → dummy mode, no API call, no AppLoader, renders EventModel fields directly
  const testEvent = EventModel(
    id: '',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 350.0,
    tag: 'Kids & Family',
    description: 'A super fun event for kids.',
  );

  setUp(() {
    AuthState.isLoggedIn.value = false;
  });

  group('EventDetailScreen Tests', () {
    testWidgets('renders all event details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        expect(find.text('Awesome Kids Event'), findsOneWidget);
        expect(find.text('Central Park'), findsWidgets);
        expect(find.text('Kids & Family'), findsOneWidget);
        expect(find.textContaining('A super fun event for kids.'), findsOneWidget);
        // Bottom bar: the amount plus its "onwards" qualifier, collapsed.
        // It read '₹350/' until the trailing slash — which named no unit —
        // was replaced.
        expect(find.text('₹350 onwards', findRichText: true), findsOneWidget);
        expect(find.text('Book Now'), findsOneWidget);
      });
    });

    testWidgets('shows login sheet when Book Now is tapped while logged out', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        AuthState.isLoggedIn.value = false;
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();

        expect(find.text('Login to explore amazing kids events!'), findsOneWidget);
      });
    });

    testWidgets(
        'shows featured-highlight snackbar when Book Now is tapped on a dummy event with no API id',
        (WidgetTester tester) async {
      // Regression guard for the "Booking Unavailable" bug — featured /
      // dummy cards (id: '') must NOT navigate into the booking flow,
      // since they have no API UUID to initiate against.
      await mockNetworkImages(() async {
        AuthState.isLoggedIn.value = true;
        await pumpTLBApp(tester, const EventDetailScreen(event: testEvent));

        await tester.tap(find.text('Book Now'));
        await tester.pump(); // settle one frame for the snackbar

        // Still on the same screen (no navigation happened).
        expect(find.text('Book Now'), findsOneWidget);
        // Snackbar surfaced the helpful message instead.
        expect(
          find.textContaining('not a bookable listing yet'),
          findsOneWidget,
        );
      });
    });
  });
}
