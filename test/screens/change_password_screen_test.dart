import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tlb_mobile_ui/screens/change_password_screen.dart';
import 'package:tlb_mobile_ui/services/auth_service.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

// Mock AuthService is tricky because it's static. 
// But we can check for UI changes based on simulated state.

void main() {
  group('ChangePasswordScreen Tests', () {
    setUp(() {
      AuthState.accessToken = 'fake_token';
    });

    testWidgets('shows error when passwords do not match', (WidgetTester tester) async {
      await pumpTLBApp(tester, const ChangePasswordScreen());

      // Enter mismatched passwords
      await tester.enterText(find.widgetWithText(TextField, 'Enter current password'), 'oldpassword');
      await tester.enterText(find.widgetWithText(TextField, 'Enter new password'), 'newpassword123');
      await tester.enterText(find.widgetWithText(TextField, 'Re-enter new password'), 'mismatch');

      await tester.tap(find.text('Update Password'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (WidgetTester tester) async {
      await pumpTLBApp(tester, const ChangePasswordScreen());

      await tester.enterText(find.widgetWithText(TextField, 'Enter current password'), 'oldpassword');
      await tester.enterText(find.widgetWithText(TextField, 'Enter new password'), 'short');
      await tester.enterText(find.widgetWithText(TextField, 'Re-enter new password'), 'short');

      await tester.tap(find.text('Update Password'));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });
  });
}
