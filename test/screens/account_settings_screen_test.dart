import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/account_settings_screen.dart';
import 'package:tlb_mobile_ui/screens/change_password_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  setUp(() {
    // Set up mock auth state
    AuthState.userEmail = 'john@example.com';
    AuthState.avatarUrl.value = null; // Will fallback to initials
    AuthState.userData = {
      'profile': {
        'first_name': 'John',
      }
    };
  });

  group('AccountSettingsScreen Tests', () {
    testWidgets('renders account settings correctly', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const AccountSettingsScreen());

        // Verify title
        expect(find.text('Account Settings'), findsOneWidget);

        // Verify personal info card elements
        expect(find.text('Personal Info'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Change Password'), findsOneWidget);

        // Verify privacy card elements
        expect(find.text('Privacy'), findsOneWidget);
        expect(find.text('Manage Permissions'), findsOneWidget);
        expect(find.text('Delete Account'), findsOneWidget);
      });
    });

    testWidgets('ValueListenableBuilder updates UI when avatarUrl changes', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const AccountSettingsScreen());

        // Initial state
        expect(find.byType(CircleAvatar), findsOneWidget);

        // Change the listenable value
        AuthState.avatarUrl.value = 'https://example.com/new_avatar.jpg';
        await tester.pumpAndSettle();

        // UI should rebuild and still have the avatar
        expect(find.byType(CircleAvatar), findsOneWidget);
      });
    });

    testWidgets('navigates to ChangePasswordScreen when tapped', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const AccountSettingsScreen());

        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        expect(find.byType(ChangePasswordScreen), findsOneWidget);
      });
    });
  });
}
