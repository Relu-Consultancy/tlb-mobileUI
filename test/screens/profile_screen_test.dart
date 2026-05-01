import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/profile_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() {
    // Set up mock auth state
    AuthState.userName.value = 'John Doe';
    AuthState.userEmail = 'john@example.com';
    AuthState.userData = {
      'profile': {
        'first_name': 'John',
        'last_name': 'Doe',
        'date_of_birth': '1990-01-01',
      }
    };
  });

  group('ProfileScreen Tests', () {
    testWidgets('renders profile screen with mocked data', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ProfileScreen());

        // Verify header components
        expect(find.text('My Profile'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);

        // Verify menu items
        expect(find.text('All Booking'), findsOneWidget);
        expect(find.text('Favorite'), findsOneWidget);
        expect(find.text('Payment Settings'), findsOneWidget);
        expect(find.text('Your Reviews'), findsOneWidget);
        expect(find.text('Account Settings'), findsOneWidget);
        expect(find.text('Log Out'), findsOneWidget);

        // Verify profile completion text
        expect(find.text('Profile Completion'), findsOneWidget);
      });
    });

    testWidgets('shows logout dialog when Log Out is tapped', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const ProfileScreen());

        // Scroll to the bottom to ensure Log Out is visible
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        final logoutButton = find.text('Log Out').first;
        expect(logoutButton, findsOneWidget);

        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Verify the dialog appears
        expect(find.text('Are you sure you want to log out?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });
    });
  });
}
