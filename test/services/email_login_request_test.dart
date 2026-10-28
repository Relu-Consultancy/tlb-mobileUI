import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/screens/otp_verification_screen.dart';
import 'package:tlb_mobile_ui/widgets/login_sheet.dart';

import '../helpers/test_setup.dart';

/// Email login must reach the backend: tapping Send OTP posts to
/// /auth/request-otp/ with purpose "login", then opens the code screen.
void main() {
  testWidgets('TC_S_EML_001 — Send OTP posts the email to request-otp',
      (tester) async {
    final calls = <http.Request>[];
    await pumpTLBApp(tester, const LoginScreen());
    await tester.enterText(find.byType(TextField).first, 'parent@example.com');
    await http.runWithClient(() async {
      await tester.tap(find.text('Send OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }, () => MockClient((req) async {
          calls.add(req);
          return http.Response(
              '{"success":true,"data":{"message":"OTP sent successfully."}}',
              200);
        }));

    expect(calls, hasLength(1));
    expect(calls.single.method, 'POST');
    expect(calls.single.url.toString(),
        'https://tlb-api.reluconsultancy.in/api/v1/auth/request-otp/');
    expect(jsonDecode(calls.single.body), {
      'identifier': 'parent@example.com',
      'identifier_type': 'email',
      'purpose': 'login',
    });
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
