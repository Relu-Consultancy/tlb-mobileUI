import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/account_settings_screen.dart';
import 'package:tlb_mobile_ui/screens/verify_contact_screen.dart';
import 'package:tlb_mobile_ui/services/contact_verification_service.dart';

import '../helpers/test_setup.dart';

/// "Verify later": a contact is verified only by a successful OTP against that
/// contact. An email sign-in verifies the email, not the mobile number saved
/// on the profile — and the other way round.
http.Response _ok() => http.Response('{"success":true,"data":{}}', 200);

http.Response _err(String code, int status) => http.Response(
      jsonEncode({
        'success': false,
        'error': {'code': code, 'message': code}
      }),
      status,
    );

void _signInWithEmail({String? profilePhone, Map<String, dynamic>? extra}) {
  AuthState.login(
    access: 'access-123',
    refresh: 'refresh-123',
    user: {
      'id': 'u1',
      'email': 'parent@example.com',
      'role': 'customer',
      'auth_provider': 'otp',
      'is_verified': true,
      if (profilePhone != null) 'profile': {'phone_number': profilePhone},
      ...?extra,
    },
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    AuthState.logout();
  });
  tearDown(AuthState.logout);

  group('AuthState verification status', () {
    test('TC_P_VER_001 — an email sign-in verifies the email, not the mobile',
        () {
      _signInWithEmail(profilePhone: '+919876543210');
      expect(AuthState.isEmailVerified, isTrue);
      expect(AuthState.contactPhone, '+919876543210');
      expect(AuthState.isPhoneVerified, isFalse,
          reason: 'the number was never confirmed by a code');
    });

    test('TC_P_VER_002 — a phone sign-up verifies the mobile, has no email',
        () {
      AuthState.login(
        access: 'a',
        refresh: 'r',
        user: {
          'id': 'u2',
          'email': null,
          'phone': '+919876543210',
          'is_verified': true,
        },
      );
      expect(AuthState.isPhoneVerified, isTrue);
      expect(AuthState.contactEmail, isNull);
      expect(AuthState.isEmailVerified, isFalse);
    });

    test('TC_P_VER_003 — server flags win over what sign-in implies', () {
      _signInWithEmail(extra: {'email_verified': false, 'phone_verified': true});
      expect(AuthState.isEmailVerified, isFalse);
      expect(AuthState.isPhoneVerified, isTrue);
    });

    test('TC_P_VER_004 — markVerified records it and tells listeners', () {
      _signInWithEmail(profilePhone: '+919876543210');
      var rebuilt = 0;
      AuthState.verificationChanged.addListener(() => rebuilt++);
      AuthState.markVerified(phone: '+919876543210');
      expect(AuthState.isPhoneVerified, isTrue);
      expect(AuthState.isEmailVerified, isTrue, reason: 'email untouched');
      expect(rebuilt, 1);
    });
  });

  group('ContactVerificationService', () {
    test('TC_A_VER_005 — mobile: WhatsApp OTP request then verify, signed in',
        () async {
      final calls = <http.Request>[];
      _signInWithEmail(profilePhone: '+919876543210');
      await http.runWithClient(() async {
        final sent =
            await ContactVerificationService.requestPhoneOtp('+919876543210');
        expect(sent['success'], isTrue);
        expect(AuthState.isPhoneVerified, isFalse,
            reason: 'requesting a code verifies nothing');

        final done = await ContactVerificationService.verifyPhone(
            '+919876543210', '123456');
        expect(done['success'], isTrue);
      }, () => MockClient((req) async {
            calls.add(req);
            return _ok();
          }));

      expect(calls.map((c) => c.url.path), [
        '/api/v1/customer/phone/request-otp/',
        '/api/v1/customer/phone/verify/',
      ]);
      expect(calls.every((c) => c.headers['Authorization'] == 'Bearer access-123'),
          isTrue);
      expect(jsonDecode(calls[0].body), {'phone': '+919876543210'});
      expect(jsonDecode(calls[1].body),
          {'phone': '+919876543210', 'otp': '123456'});
      expect(AuthState.isPhoneVerified, isTrue);
    });

    test('TC_A_VER_006 — email: request then verify marks only the email',
        () async {
      AuthState.login(access: 'access-123', refresh: 'r', user: {
        'id': 'u2',
        'email': null,
        'phone': '+919876543210',
        'is_verified': true,
      });
      final calls = <http.Request>[];
      await http.runWithClient(() async {
        await ContactVerificationService.requestEmailOtp('a@b.co');
        await ContactVerificationService.verifyEmail('a@b.co', '654321');
      }, () => MockClient((req) async {
            calls.add(req);
            return _ok();
          }));
      expect(calls.map((c) => c.url.path), [
        '/api/v1/customer/email/request-otp/',
        '/api/v1/customer/email/verify/',
      ]);
      expect(jsonDecode(calls[1].body), {'email': 'a@b.co', 'otp': '654321'});
      expect(AuthState.isEmailVerified, isTrue);
      expect(AuthState.contactEmail, 'a@b.co');
    });

    test('TC_A_VER_007 — a wrong code leaves the contact unverified, readably',
        () async {
      _signInWithEmail(profilePhone: '+919876543210');
      final r = await http.runWithClient(
        () => ContactVerificationService.verifyPhone('+919876543210', '000000'),
        () => MockClient((_) async => _err('OTP_INVALID', 400)),
      );
      expect(r['success'], isFalse);
      expect(r['message'], 'Incorrect OTP. Please try again.');
      expect(AuthState.isPhoneVerified, isFalse);
    });

    test('TC_A_VER_008 — no endpoint yet: a plain message, nothing marked',
        () async {
      _signInWithEmail(profilePhone: '+919876543210');
      final r = await http.runWithClient(
        () => ContactVerificationService.requestPhoneOtp('+919876543210'),
        () => MockClient((_) async => http.Response('<html>404</html>', 404)),
      );
      expect(r['code'], ContactVerificationService.unavailable);
      expect(r['message'], "Verification isn't available yet. Please try again later.");
    });

    test('TC_A_VER_009 — rate limit, lock-out and an already-linked contact',
        () async {
      Future<String> msg(String code, int status) async => (await http
              .runWithClient(
        () => ContactVerificationService.requestEmailOtp('a@b.co'),
        () => MockClient((_) async => _err(code, status)),
      ))['message'] as String;
      expect(await msg('RATE_LIMIT_EXCEEDED', 429), contains('Too many requests'));
      expect(await msg('OTP_LOCKED', 429), contains('request a new OTP'));
      expect(await msg('EMAIL_IN_USE', 409), contains('already linked'));
    });

    test('TC_A_VER_010 — offline never throws', () async {
      final r = await http.runWithClient(
        () => ContactVerificationService.requestPhoneOtp('+919876543210'),
        () => MockClient((_) async => throw http.ClientException('down')),
      );
      expect(r['success'], isFalse);
      expect(r['message'], contains('internet connection'));
    });
  });

  group('screens', () {
    Future<void> openVerify(WidgetTester tester, VerifyContactKind kind) async {
      await pumpTLBApp(tester, VerifyContactScreen(kind: kind));
      await tester.pump();
    }

    testWidgets(
        'TC_S_VER_011 — Account Settings lists mobile and email with their '
        'own status', (tester) async {
      _signInWithEmail(profilePhone: '+919876543210');
      await pumpTLBApp(tester, const AccountSettingsScreen());
      await tester.pump();
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('parent@example.com'), findsWidgets);
      // Mobile not verified yet, email is.
      expect(find.text('Verify'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('TC_S_VER_012 — tapping Mobile Number opens WhatsApp '
        'verification with the saved number filled in', (tester) async {
      _signInWithEmail(profilePhone: '+919876543210');
      await pumpTLBApp(tester, const AccountSettingsScreen());
      await tester.pump();
      await tester.tap(find.text('Mobile Number'));
      await tester.pumpAndSettle();
      expect(find.text('Verify Mobile Number'), findsOneWidget);
      expect(find.text('Not verified'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '9876543210',
      );
      expect(find.text('Send OTP on WhatsApp'), findsOneWidget);
    });

    testWidgets('TC_S_VER_013 — a verified contact shows no Send button until '
        'it is changed', (tester) async {
      _signInWithEmail();
      await openVerify(tester, VerifyContactKind.email);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Send OTP to Email'), findsNothing);

      await tester.enterText(find.byType(TextField), 'new@example.com');
      await tester.pump();
      expect(find.text('Send OTP to Email'), findsOneWidget);
    });

    testWidgets('TC_S_VER_014 — a bad number makes no request', (tester) async {
      var requests = 0;
      _signInWithEmail();
      await openVerify(tester, VerifyContactKind.mobile);
      await tester.enterText(find.byType(TextField), '12345');
      await http.runWithClient(
        () => tester.tap(find.text('Send OTP on WhatsApp')),
        () => MockClient((_) async {
          requests++;
          return _ok();
        }),
      );
      await tester.pump();
      expect(find.text('Enter all 10 digits (5 so far).'), findsOneWidget);
      expect(requests, 0);
    });

    testWidgets('TC_S_VER_015 — the full mobile flow: send, enter the code, '
        'verified', (tester) async {
      _signInWithEmail(profilePhone: '+919876543210');
      await pumpTLBApp(tester, const AccountSettingsScreen());
      await tester.pump();
      await tester.tap(find.text('Mobile Number'));
      await tester.pumpAndSettle();

      final calls = <String>[];
      await http.runWithClient(() async {
        await tester.tap(find.text('Send OTP on WhatsApp'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('WhatsApp Verification'), findsOneWidget);

        final boxes = find.byType(TextField);
        for (var i = 0; i < 6; i++) {
          await tester.enterText(boxes.at(i), '${i + 1}');
        }
        await tester.pump();
        await tester.tap(find.text('Verify & Continue'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();
      }, () => MockClient((req) async {
            calls.add(req.url.path);
            return _ok();
          }));

      expect(calls, [
        '/api/v1/customer/phone/request-otp/',
        '/api/v1/customer/phone/verify/',
      ]);
      expect(AuthState.isPhoneVerified, isTrue);
      // Back on Account Settings, which now shows both as verified.
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Verified'), findsNWidgets(2));
      expect(find.text('Verify'), findsNothing);
    });

    testWidgets('TC_S_VER_016 — with no endpoint yet the screen says so and '
        'stays put', (tester) async {
      _signInWithEmail(profilePhone: '+919876543210');
      await openVerify(tester, VerifyContactKind.mobile);
      await http.runWithClient(
        () async {
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
        },
        () => MockClient((_) async => http.Response('', 404)),
      );
      expect(find.text("Verification isn't available yet. Please try again later."),
          findsOneWidget);
      expect(find.text('WhatsApp Verification'), findsNothing);
    });
  });
}
