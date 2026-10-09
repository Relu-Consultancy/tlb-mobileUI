import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/core/phone_validation.dart';
import 'package:tlb_mobile_ui/screens/otp_verification_screen.dart';
import 'package:tlb_mobile_ui/screens/signup_screen.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_login_screen.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_signup_screen.dart';
import 'package:tlb_mobile_ui/services/auth_service.dart';
import 'package:tlb_mobile_ui/widgets/login_sheet.dart';

import '../helpers/test_setup.dart';

/// Mobile (WhatsApp) OTP: POST /auth/request-otp/ and /auth/verify-otp/ with
/// `identifier_type: "phone"` and an E.164 number. The 6-digit code arrives on
/// WhatsApp.
const _phone = '+919876543210';

http.Response _error(String code, int status) => http.Response(
      jsonEncode({
        'success': false,
        'data': null,
        'error': {'code': code, 'message': code},
      }),
      status,
    );

http.Response _verified() => http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'access_token': 'access-abc',
          'refresh_token': 'refresh-abc',
          'user': {
            'id': '3d52dbe8-dfa8-4966-b21c-aa55bd4d8a3e',
            'email': null,
            'phone': _phone,
            'role': 'customer',
            'auth_provider': 'otp',
            'is_verified': true,
          },
        },
      }),
      200,
    );

void main() {
  group('request-otp', () {
    test('TC_A_WA_001 — sends the phone identifier, type and purpose',
        () async {
      late Map<String, dynamic> sent;
      final result = await http.runWithClient(
        () => AuthService.requestOtp(
          identifier: _phone,
          identifierType: 'phone',
          purpose: 'login',
        ),
        () => MockClient((req) async {
          expect(req.url.path, '/api/v1/auth/request-otp/');
          expect(req.headers.containsKey('Authorization'), isFalse);
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(
              jsonEncode({
                'success': true,
                'data': {'message': 'OTP sent successfully.'},
                'error': null,
              }),
              200);
        }),
      );
      expect(sent, {
        'identifier': _phone,
        'identifier_type': 'phone',
        'purpose': 'login',
      });
      expect(result['success'], isTrue);
    });

    test('TC_A_WA_002 — email is still the default type', () async {
      late Map<String, dynamic> sent;
      await http.runWithClient(
        () => AuthService.requestOtp(identifier: 'a@b.co'),
        () => MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response('{"success":true,"data":{}}', 200);
        }),
      );
      expect(sent['identifier_type'], 'email');
    });

    test('TC_A_WA_003 — an unregistered number on login says to sign up',
        () async {
      final r = await http.runWithClient(
        () => AuthService.requestOtp(
            identifier: _phone, identifierType: 'phone', purpose: 'login'),
        () => MockClient((_) async => _error('USER_NOT_FOUND', 400)),
      );
      expect(r['code'], 'USER_NOT_FOUND');
      expect(r['message'], 'Account not found. Please signup first.');
    });

    test('TC_A_WA_004 — rate limit and blocked accounts read plainly',
        () async {
      Future<Map<String, dynamic>> call(http.Response res) =>
          http.runWithClient(
            () => AuthService.requestOtp(
                identifier: _phone, identifierType: 'phone'),
            () => MockClient((_) async => res),
          );

      final limited = await call(_error('RATE_LIMIT_EXCEEDED', 429));
      expect(limited['message'], contains('Too many requests'));
      expect(limited['message'], isNot(contains('RATE_LIMIT')));

      final deleted = await call(_error('ACCOUNT_DELETED', 403));
      expect(deleted['message'], contains('deleted'));
      final disabled = await call(_error('ACCOUNT_DISABLED', 403));
      expect(disabled['message'], contains('disabled'));
    });
  });

  group('verify-otp', () {
    test('TC_A_WA_005 — sends identifier_type phone, the code and the role',
        () async {
      late Map<String, dynamic> sent;
      final result = await http.runWithClient(
        () => AuthService.verifyOtp(
            identifier: _phone, identifierType: 'phone', otp: '123456'),
        () => MockClient((req) async {
          expect(req.url.path, '/api/v1/auth/verify-otp/');
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return _verified();
        }),
      );
      expect(sent, {
        'identifier': _phone,
        'identifier_type': 'phone',
        'otp': '123456',
        'role': 'customer',
      });
      expect(result['success'], isTrue);
      expect(result['access'], 'access-abc');
      expect((result['user'] as Map)['email'], isNull,
          reason: 'a phone signup has no email');
      expect((result['user'] as Map)['phone'], _phone);
    });

    test('TC_A_WA_006 — every documented error code has a readable message',
        () async {
      final cases = <(String, int, String)>[
        ('OTP_INVALID', 400, 'Incorrect OTP'),
        ('OTP_EXPIRED', 400, 'expired'),
        ('OTP_LOCKED', 429, 'request a new OTP'),
        ('RATE_LIMIT_EXCEEDED', 429, 'Too many'),
        ('USER_ROLE_MISMATCH', 400, 'partner'),
        ('ACCOUNT_DELETED', 403, 'deleted'),
        ('ACCOUNT_DISABLED', 403, 'disabled'),
      ];
      for (final (code, status, expected) in cases) {
        final r = await http.runWithClient(
          () => AuthService.verifyOtp(
              identifier: _phone, identifierType: 'phone', otp: '000000'),
          () => MockClient((_) async => _error(code, status)),
        );
        expect(r['success'], isFalse, reason: code);
        expect(r['code'], code, reason: code);
        expect(r['message'], contains(expected), reason: code);
        expect(r['message'], isNot(contains(code)), reason: code);
      }
    });

    test('TC_A_WA_007 — a brand-new phone account is recognised as new',
        () async {
      // No new-user flag in the reply; the empty profile says it is new.
      final isNew = await http.runWithClient(
        () async {
          final r = await AuthService.verifyOtp(
              identifier: _phone, identifierType: 'phone', otp: '123456');
          return AuthService.isNewAccount(r);
        },
        () => MockClient((req) async {
          if (req.url.path.endsWith('/customer/profile/')) {
            return http.Response(
                jsonEncode({
                  'success': true,
                  'data': {'first_name': '', 'is_completed': false},
                }),
                200);
          }
          return _verified();
        }),
      );
      expect(isNew, isTrue);
    });
  });

  // The backend as deployed on 9 Oct: no phone support yet. Verbatim reply.
  group('server without WhatsApp OTP yet', () {
    final oldServer = http.Response(
      jsonEncode({
        'success': false,
        'data': null,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': "{'identifier': [ErrorDetail(string='Enter a valid email "
              "address.', code='invalid')], 'identifier_type': "
              "[ErrorDetail(string='\"phone\" is not a valid choice.', "
              "code='invalid_choice')]}",
        },
      }),
      400,
    );

    test('TC_A_WA_019 — a phone number is never called an invalid email',
        () async {
      final request = await http.runWithClient(
        () => AuthService.requestOtp(
            identifier: _phone, identifierType: 'phone', purpose: 'login'),
        () => MockClient((_) async => oldServer),
      );
      expect(request['code'], AuthService.phoneOtpUnavailable);
      expect(request['message'], "WhatsApp OTP isn't available yet. Please use email for now.");
      expect(request['message'], isNot(contains('email address')));

      final verify = await http.runWithClient(
        () => AuthService.verifyOtp(
            identifier: _phone, identifierType: 'phone', otp: '123456'),
        () => MockClient((_) async => oldServer),
      );
      expect(verify['code'], AuthService.phoneOtpUnavailable);
    });

    test('TC_A_WA_020 — an email request keeps its own validation message',
        () async {
      final r = await http.runWithClient(
        () => AuthService.requestOtp(identifier: 'abc123'),
        () => MockClient((_) async => oldServer),
      );
      expect(r['code'], 'VALIDATION_ERROR');
      expect(r['message'], isNot(contains('WhatsApp')));
    });

    testWidgets('TC_S_WA_021 — the WhatsApp screen shows that, not the email '
        'error', (tester) async {
      await pumpTLBApp(tester, const WhatsAppLoginScreen());
      await tester.enterText(find.byType(TextField).first, '9354384545');
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        },
        () => MockClient((_) async => oldServer),
      );
      expect(find.text("WhatsApp OTP isn't available yet. Please use email for now."),
          findsOneWidget);
      expect(find.textContaining('valid email'), findsNothing);
    });
  });

  group('IndianPhone', () {
    test('TC_C_WA_008 — E.164 for the API, spaced for display', () {
      expect(IndianPhone.e164('98765 43210'), _phone);
      expect(IndianPhone.e164('+91 98765-43210'), _phone);
      expect(IndianPhone.display(_phone), '+91 98765 43210');
      expect(IndianPhone.display('abc'), 'abc');
    });
  });

  group('screens', () {
    testWidgets(
        'TC_S_WA_009 — email login is unchanged; WhatsApp is a separate '
        'screen reached from it', (tester) async {
      await pumpTLBApp(tester, const LoginScreen());
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);
      expect(find.text('WhatsApp Number'), findsNothing);

      await tester.ensureVisible(find.text('Continue with WhatsApp'));
      await tester.tap(find.text('Continue with WhatsApp'));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsAppLoginScreen), findsOneWidget);
      expect(find.text('Login with WhatsApp'), findsOneWidget);
      expect(find.text('WhatsApp Number'), findsOneWidget);
      expect(find.text('Email Address'), findsNothing);
    });

    testWidgets('TC_S_WA_010 — email sign-up is unchanged; WhatsApp sign-up '
        'is its own screen', (tester) async {
      await pumpTLBApp(tester, const SignupScreen());
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Send OTP'), findsOneWidget);

      await tester.ensureVisible(find.text('Signup with WhatsApp'));
      await tester.tap(find.text('Signup with WhatsApp'));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsAppSignupScreen), findsOneWidget);
      expect(find.text('WhatsApp Number'), findsOneWidget);
    });

    testWidgets('TC_S_WA_015 — the number field takes digits only and a bad '
        'number makes no request', (tester) async {
      var requests = 0;
      await pumpTLBApp(tester, const WhatsAppLoginScreen());
      await tester.enterText(find.byType(TextField).first, '98a76-5 43210x99');
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '9876543210',
      );
      await tester.enterText(find.byType(TextField).first, '12345');
      await http.runWithClient(
        () => tester.tap(find.text('Send OTP on WhatsApp')),
        () => MockClient((_) async {
          requests++;
          return _error('VALIDATION_ERROR', 400);
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Enter all 10 digits (5 so far).'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets(
        'TC_S_WA_011 — WhatsApp login requests a phone OTP (login) and opens '
        'the WhatsApp verification screen', (tester) async {
      Map<String, dynamic>? sent;
      await pumpTLBApp(tester, const WhatsAppLoginScreen());
      await tester.enterText(find.byType(TextField).first, '9876543210');
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        },
        () => MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(
              '{"success":true,"data":{"message":"OTP sent successfully."}}',
              200);
        }),
      );
      expect(sent, {
        'identifier': _phone,
        'identifier_type': 'phone',
        'purpose': 'login',
      });
      expect(find.text('WhatsApp Verification'), findsOneWidget);
      expect(find.textContaining('+91 98765 43210'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_WA_016 — WhatsApp sign-up requests purpose register',
        (tester) async {
      Map<String, dynamic>? sent;
      await pumpTLBApp(tester, const WhatsAppSignupScreen());
      await tester.enterText(find.byType(TextField).first, '9876543210');
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        },
        () => MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response('{"success":true,"data":{}}', 200);
        }),
      );
      expect(sent!['purpose'], 'register');
      expect(sent!['identifier_type'], 'phone');
      expect(find.text('WhatsApp Verification'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_WA_017 — an unregistered number on WhatsApp login '
        'says to sign up, and stays put', (tester) async {
      await pumpTLBApp(tester, const WhatsAppLoginScreen());
      await tester.enterText(find.byType(TextField).first, '9876543210');
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        },
        () => MockClient((_) async => _error('USER_NOT_FOUND', 400)),
      );
      expect(find.text('Account not found. Please signup first.'),
          findsOneWidget);
      expect(find.text('WhatsApp Verification'), findsNothing);
    });

    testWidgets('TC_S_WA_018 — the two WhatsApp screens link to each other',
        (tester) async {
      await pumpTLBApp(tester, const WhatsAppLoginScreen());
      await tester.tap(find.text('Signup with WhatsApp'));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsAppSignupScreen), findsOneWidget);
      await tester.tap(find.text('Login with WhatsApp'));
      await tester.pumpAndSettle();
      expect(find.byType(WhatsAppLoginScreen), findsOneWidget);
    });

    testWidgets('TC_S_WA_012 — the verification screen names WhatsApp and '
        'keeps the 30-second resend wait', (tester) async {
      await pumpTLBApp(
        tester,
        const OtpVerificationScreen(
            identifier: _phone, identifierType: 'phone'),
      );
      expect(find.text('WhatsApp Verification'), findsOneWidget);
      expect(find.textContaining('sent on WhatsApp'), findsOneWidget);
      expect(find.text('Resend in 00:30'), findsOneWidget);

      await tester.pump(const Duration(seconds: 30));
      expect(find.text('Resend OTP'), findsOneWidget);
      // Leave nothing running.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_WA_013 — an email OTP screen is unchanged',
        (tester) async {
      await pumpTLBApp(
        tester,
        const OtpVerificationScreen(identifier: 'a@b.co'),
      );
      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('WhatsApp Verification'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_WA_014 — resending asks for a phone OTP again and says '
        'it went on WhatsApp', (tester) async {
      Map<String, dynamic>? sent;
      await pumpTLBApp(
        tester,
        const OtpVerificationScreen(
            identifier: _phone, identifierType: 'phone', isLoginFlow: true),
      );
      await tester.pump(const Duration(seconds: 30));
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Resend OTP'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        },
        () => MockClient((req) async {
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response('{"success":true,"data":{}}', 200);
        }),
      );
      expect(sent, {
        'identifier': _phone,
        'identifier_type': 'phone',
        'purpose': 'login',
      });
      expect(find.text('OTP resent on WhatsApp'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
