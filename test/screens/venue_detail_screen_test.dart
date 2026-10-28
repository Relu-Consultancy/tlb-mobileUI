import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/venue_detail_screen.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  // id: '' → dummy mode, no API call
  final testEvent = EventModel(
    id: '',
    title: 'Test Venue Detail',
    imagePath: 'assets/images/test.png',
    venue: 'Magic Land',
    price: 350,
    tag: 'Adventure',
  );

  group('VenueDetailScreen Tests', () {
    testWidgets('renders venue details correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, VenueDetailScreen(event: testEvent));

        expect(find.text('Test Venue Detail'), findsOneWidget);
        // Venue name may appear in multiple places (header, info row, etc.)
        expect(find.text('Magic Land'), findsWidgets);
        expect(find.text('Adventure'), findsOneWidget);
        // Bottom bar: the amount plus its "onwards" qualifier, collapsed.
        // It read '₹350/' until the trailing slash — which named no unit —
        // was replaced.
        expect(find.text('₹350 onwards', findRichText: true), findsOneWidget);
        expect(find.text('Check Availability'), findsOneWidget);
      });
    });

    testWidgets('shows login sheet when Check Availability is tapped and not logged in', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        AuthState.isLoggedIn.value = false;
        await pumpTLBApp(tester, VenueDetailScreen(event: testEvent));

        await tester.tap(find.text('Check Availability'));
        await tester.pumpAndSettle();

        // Login sheet title shown by showLoginSheet()
        expect(find.text("Let's Get Started!"), findsOneWidget);
      });
    });
  });
}
