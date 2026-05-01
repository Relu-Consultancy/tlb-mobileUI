import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/screens/edit_profile_screen.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';

import '../helpers/test_setup.dart';

void main() {
  group('EditProfileScreen Tests', () {
    setUp(() {
      AuthState.userData = {
        'profile': {
          'first_name': 'John',
          'last_name': 'Doe',
          'city': 'Mumbai',
          'state': 'Maharashtra',
        }
      };
    });

    testWidgets('pre-fills fields from AuthState', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EditProfileScreen());

        expect(find.widgetWithText(TextField, 'John'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Doe'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Mumbai'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Maharashtra'), findsOneWidget);
      });
    });

    testWidgets('shows error if first name is empty on save', (WidgetTester tester) async {
      await mockNetworkImages(() async {
        await pumpTLBApp(tester, const EditProfileScreen());

        // Clear first name
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
