import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tlb_mobile_ui/screens/forgot_password_screen.dart';

import '../helpers/test_setup.dart';

void main() {
  group('ForgotPasswordScreen Tests', () {
    testWidgets('renders initial step (email entry)', (WidgetTester tester) async {
      await pumpTLBApp(tester, const ForgotPasswordScreen());

      // Verify header texts
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
      
      // Verify text field exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error on invalid email', (WidgetTester tester) async {
      await pumpTLBApp(tester, const ForgotPasswordScreen());

      final sendOtpButton = find.widgetWithText(ElevatedButton, 'Send OTP');
      final emailField = find.byType(TextField);

      // Enter invalid email
      await tester.enterText(emailField, 'invalidemail');
      await tester.tap(sendOtpButton);
      await tester.pumpAndSettle();

      // Verify validation snackbar
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows validation error on empty email', (WidgetTester tester) async {
      await pumpTLBApp(tester, const ForgotPasswordScreen());

      final sendOtpButton = find.widgetWithText(ElevatedButton, 'Send OTP');

      // Tap without entering anything
      await tester.tap(sendOtpButton);
      await tester.pumpAndSettle();

      // Verify validation snackbar
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });
  });
}
