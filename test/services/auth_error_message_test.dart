import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/services/auth_service.dart';
import 'package:tlb_mobile_ui/widgets/login_sheet.dart';

import '../helpers/test_setup.dart';

/// bug_login_001 — an improperly formatted email on the login page showed the
/// server's error "in code format":
///   {'identifier': [ErrorDetail(string='Enter a valid email address.', …)]}
/// The format is now checked before any request, and whatever the server
/// sends is made readable before it is shown.

/// The live API's reply to request-otp with identifier "abc123".
final _validationReply = http.Response(
  jsonEncode({
    'success': false,
    'data': null,
    'error': {
      'code': 'VALIDATION_ERROR',
      'message': "{'identifier': [ErrorDetail(string='Enter a valid email "
          "address.', code='invalid')]}",
    },
  }),
  400,
);

void main() {
  group('AuthService.requestOtp', () {
    test('TC_A_AUTHERR_001 — the server\'s validation error comes back readable',
        () async {
      final result = await http.runWithClient(
        () => AuthService.requestOtp(identifier: 'abc123', purpose: 'login'),
        () => MockClient((_) async => _validationReply),
      );
      expect(result['success'], isFalse);
      expect(result['message'], 'Enter a valid email address.');
    });

    test('TC_A_AUTHERR_002 — a network failure shows no exception text',
        () async {
      final result = await http.runWithClient(
        () => AuthService.requestOtp(identifier: 'parent@example.com'),
        () => MockClient((_) async =>
            throw const SocketException('Failed host lookup: tlb-api')),
      );
      final message = result['message'] as String;
      expect(message, isNot(contains('Failed host lookup')));
      expect(message, isNot(contains('Exception')));
      expect(message, contains('internet connection'));
    });
  });

  group('LoginScreen', () {
    testWidgets(
        'TC_S_AUTHERR_003 — "abc123" gets a plain message and no request is '
        'made', (tester) async {
      var requests = 0;
      await pumpTLBApp(tester, const LoginScreen());
      await tester.enterText(find.byType(TextField).first, 'abc123');
      await http.runWithClient(
        () => tester.tap(find.text('Send OTP')),
        () => MockClient((_) async {
          requests++;
          return _validationReply;
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.textContaining('ErrorDetail'), findsNothing);
      expect(requests, 0);
    });
  });
}
