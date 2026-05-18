import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/edit_profile_screen.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  group('EditProfileScreen Tests', () {
    setUp(() {
      // Session 12: fields changed to first_name, last_name, phone_number, region
      AuthState.userData = {
        'profile': {
          'first_name': 'John',
          'last_name': 'Doe',
          'phone_number': '+91 9876543210',
          'region': 'Maharashtra',
        }
      };
    });

    testWidgets('pre-fills fields from AuthState', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EditProfileScreen());

        expect(find.widgetWithText(TextField, 'John'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Doe'), findsOneWidget);
        // Country code is shown in the prefix button (not a TextField);
        // the phone TextField receives only the local digits.
        expect(find.text('+91'), findsOneWidget);
        expect(find.widgetWithText(TextField, '9876543210'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Maharashtra'), findsOneWidget);
      });
    });

    testWidgets('shows error snackbar if first name is empty on save', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EditProfileScreen());

        await tester.enterText(find.widgetWithText(TextField, 'John'), '');

        final saveBtn = find.text('Update Profile');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        expect(find.text('First name is required'), findsOneWidget);
      });
    });
  });
}
