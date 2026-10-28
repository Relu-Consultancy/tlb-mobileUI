import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/models/event_model.dart';
import 'package:tlb_mobile_ui/screens/ticket_booking_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  const testEvent = EventModel(
    id: 'e1',
    title: 'Awesome Kids Event',
    venue: 'Central Park',
    imagePath: 'assets/images/placeholder.png',
    price: 360.0,
  );

  group('TicketBookingScreen Tests', () {
    testWidgets('renders screen and subtotal updates when tickets are added', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const TicketBookingScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
          ),
        );

        // Verify title
        expect(find.text('Checkout'), findsOneWidget);
        expect(find.text('Awesome Kids Event'), findsOneWidget);

        // Initial subtotal is 0
        expect(find.text('₹0'), findsWidgets);

        // Find the 'Add' button for the first ticket (Standard) and tap it
        final addButtons = find.widgetWithText(OutlinedButton, 'Add');
        expect(addButtons, findsWidgets); // Multiple ticket types

        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();

        // Subtotal should update to ₹360 (price of first ticket)
        expect(find.text('₹360'), findsWidgets);

        // Verify the increment button appeared
        expect(find.byIcon(Icons.add), findsWidgets);

        // Add another ticket of the same type
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();

        // Subtotal should update to ₹720
        expect(find.text('₹720'), findsWidgets);
      });
    });

    testWidgets('Proceed to Pay is disabled if form is incomplete', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const TicketBookingScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
          ),
        );

        // It should be disabled initially (because count = 0 and form empty)
        // Find the Proceed button by taking the last ElevatedButton (which is in the bottom bar)
        final proceedButton = find.byType(ElevatedButton).last;
        final buttonWidget = tester.widget<ElevatedButton>(proceedButton);
        expect(buttonWidget.enabled, isFalse);

        // Add a ticket
        await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
        await tester.pumpAndSettle();

        // Still disabled because form (child name, age, phone) is empty
        final buttonWidgetAfterTicket = tester.widget<ElevatedButton>(proceedButton);
        expect(buttonWidgetAfterTicket.enabled, isFalse);
      });
    });

    testWidgets('Proceed to Pay enables when form is completely filled', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(
          tester,
          const TicketBookingScreen(
            event: testEvent,
            selectedDate: 'Sat, 21 Mar',
            selectedTime: '3:00 PM',
          ),
        );

        // 1. Add a ticket
        await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
        await tester.pumpAndSettle();

        // 2. Fill child name
        await tester.enterText(find.byType(TextField).first, 'John Doe');
        await tester.pumpAndSettle();

        // 3. Fill phone number
        await tester.enterText(find.byType(TextField).last, '9876543210');
        await tester.pumpAndSettle();

        // 4. Select age from Dropdown
        final ageDropdown = find.byType(DropdownButton<String>);
        await tester.ensureVisible(ageDropdown);
        await tester.tap(ageDropdown);
        await tester.pumpAndSettle();
        
        final ageOption = find.text('5').last;
        await tester.ensureVisible(ageOption);
        await tester.tap(ageOption); // Select age 5
        await tester.pumpAndSettle();

        // Verify button is now enabled
        // Due to dynamic text 'Proceed to Pay • ₹360', we find by type and check if any is enabled
        final proceedButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
        // The last elevated button is usually the bottom nav bar one
        final proceedButtonWidget = proceedButtons.last;
        expect(proceedButtonWidget.enabled, isTrue);
      });
    });
  });
}
