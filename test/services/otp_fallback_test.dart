import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/models/otp_delivery_model.dart';
import 'package:tlb_mobile_ui/screens/otp_verification_screen.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_login_screen.dart';
import 'package:tlb_mobile_ui/screens/whatsapp_signup_screen.dart';
import 'package:tlb_mobile_ui/services/auth_service.dart';

import '../helpers/test_setup.dart';

/// OTP delivery tracking and channel fallback: `request-otp` now reports how
/// the send is going (`otp_id` + `status`), `otp-delivery-status/` is polled
/// for it, and `send-otp-via-email/` / `send-otp-via-whatsapp/` move the SAME
/// code to the other channel. Verify always uses the identifier the flow
/// started with.
const _phone = '+919876543210';
const _email = 'user@example.com';

/// A `request-otp` / status reply for the WhatsApp flow.
Map<String, dynamic> _phoneData({
  String status = 'queued',
  bool emailSent = false,
  bool fallbackAvailable = true,
  String? emailHint = 'u***@example.com',
  String otpId = 'otp-1',
}) =>
    {
      'message': 'OTP sent successfully.',
      'otp_id': otpId,
      'channel': 'whatsapp',
      'status': status,
      'email_sent': emailSent,
      'fallback_available': fallbackAvailable,
      'fallback_channel': 'email',
      'email_hint': emailHint,
      'alternate': null,
      'expires_at': '2026-10-12T10:05:00+00:00',
    };

/// A `request-otp` / status reply for the email flow, whose fallback is the
/// `alternate` block rather than `fallback_available`.
Map<String, dynamic> _emailData({
  bool available = true,
  String mode = 'verified_phone',
  bool separateAccount = false,
  int resendCount = 3,
}) =>
    {
      'message': 'OTP sent successfully.',
      'otp_id': 'otp-1',
      'channel': 'email',
      'status': 'sent',
      'email_sent': false,
      'fallback_available': false,
      'fallback_channel': null,
      'email_hint': null,
      'alternate': {
        'channel': 'whatsapp',
        'mode': mode,
        'available': available,
        'separate_account': separateAccount,
        'phone_hint': '+91********10',
        'resend_count': resendCount,
        'resends_required': 3,
      },
      'expires_at': '2026-10-12T10:05:00+00:00',
    };

http.Response _ok(Map<String, dynamic> data) =>
    http.Response(jsonEncode({'success': true, 'data': data, 'error': null}), 200);

http.Response _err(String code, int status) => http.Response(
      jsonEncode({
        'success': false,
        'data': null,
        'error': {'code': code, 'message': code},
      }),
      status,
    );

void main() {
  group('request-otp delivery block', () {
    test('TC_A_FB_001 — fallback_email is only sent when there is one',
        () async {
      late Map<String, dynamic> sent;
      Future<void> call({String? fallbackEmail}) => http.runWithClient(
            () => AuthService.requestOtp(
              identifier: _phone,
              identifierType: 'phone',
              purpose: 'login',
              fallbackEmail: fallbackEmail,
            ),
            () => MockClient((req) async {
              sent = jsonDecode(req.body) as Map<String, dynamic>;
              return _ok(_phoneData());
            }),
          );

      // Unchanged body when no address is offered — an older server would
      // reject a key it doesn't know.
      await call();
      expect(sent, {
        'identifier': _phone,
        'identifier_type': 'phone',
        'purpose': 'login',
      });

      await call(fallbackEmail: '  $_email  ');
      expect(sent['fallback_email'], _email, reason: 'trimmed, and included');

      // A blank field on the login screen is not an address.
      await call(fallbackEmail: '   ');
      expect(sent.containsKey('fallback_email'), isFalse);
    });

    test('TC_A_FB_002 — the delivery state is parsed off a successful send',
        () async {
      final r = await http.runWithClient(
        () => AuthService.requestOtp(
            identifier: _phone, identifierType: 'phone', purpose: 'login'),
        () => MockClient((_) async => _ok(_phoneData())),
      );
      final d = r['delivery'] as OtpDelivery;
      expect(r['success'], isTrue);
      expect(d.otpId, 'otp-1');
      expect(d.channel, 'whatsapp');
      expect(d.status, OtpDeliveryStatus.queued);
      expect(d.status.isPending, isTrue);
      expect(d.status.isSettled, isFalse);
      expect(d.emailSent, isFalse);
      expect(d.canSendToEmail, isTrue);
      expect(d.emailHint, 'u***@example.com');
      expect(d.expiresAt, DateTime.parse('2026-10-12T10:05:00+00:00'));
      expect(d.alternate, isNull);
    });

    test('TC_A_FB_003 — a server with no otp_id leaves delivery null',
        () async {
      // The pre-fallback backend: success, but nothing to poll or switch.
      final r = await http.runWithClient(
        () => AuthService.requestOtp(identifier: _email),
        () => MockClient((_) async => _ok({'message': 'OTP sent successfully.'})),
      );
      expect(r['success'], isTrue);
      expect(r['delivery'], isNull);
    });

    test('TC_A_FB_004 — an email login parses the alternate block', () async {
      final r = await http.runWithClient(
        () => AuthService.requestOtp(identifier: _email, purpose: 'login'),
        () => MockClient((_) async => _ok(_emailData())),
      );
      final a = (r['delivery'] as OtpDelivery).alternate!;
      expect(a.mode, OtpAlternateMode.verifiedPhone);
      expect(a.available, isTrue);
      expect(a.canSendToWhatsApp, isTrue);
      expect(a.needsPhoneLogin, isFalse);
      expect(a.phoneHint, '+91********10');
      expect(a.resendCount, 3);
      expect(a.resendsRequired, 3);
    });
  });

  group('delivery status & channel switch', () {
    test('TC_A_FB_005 — status is a GET carrying otp_id, with no auth header',
        () async {
      late Uri url;
      final r = await http.runWithClient(
        () => AuthService.otpDeliveryStatus(otpId: 'otp-1'),
        () => MockClient((req) async {
          url = req.url;
          expect(req.method, 'GET');
          expect(req.headers.containsKey('Authorization'), isFalse);
          return _ok(_phoneData(status: 'delivered'));
        }),
      );
      expect(url.path, '/api/v1/auth/otp-delivery-status/');
      expect(url.queryParameters, {'otp_id': 'otp-1'});
      final d = r['delivery'] as OtpDelivery;
      expect(d.status, OtpDeliveryStatus.delivered);
      expect(d.status.isSettled, isTrue, reason: 'polling can stop');
    });

    test('TC_A_FB_006 — a WhatsApp failure reports the automatic email',
        () async {
      final r = await http.runWithClient(
        () => AuthService.otpDeliveryStatus(otpId: 'otp-1'),
        () => MockClient((_) async =>
            _ok(_phoneData(status: 'failed', emailSent: true))),
      );
      final d = r['delivery'] as OtpDelivery;
      expect(d.status, OtpDeliveryStatus.failed);
      expect(d.emailSent, isTrue);
      // Already emailed, so asking again would only earn EMAIL_ALREADY_SENT.
      expect(d.canSendToEmail, isFalse);
      expect(d.needsEmailAddress, isFalse);
    });

    test('TC_A_FB_007 — a failure with no address on file needs one asked for',
        () async {
      final r = await http.runWithClient(
        () => AuthService.otpDeliveryStatus(otpId: 'otp-1'),
        () => MockClient((_) async => _ok(_phoneData(
            status: 'failed', fallbackAvailable: false, emailHint: null))),
      );
      final d = r['delivery'] as OtpDelivery;
      expect(d.needsEmailAddress, isTrue);
      expect(d.canSendToEmail, isFalse);
      expect(d.emailHint, isNull);
    });

    test('TC_A_FB_008 — both switch endpoints post just the otp_id', () async {
      for (final (call, path) in <(Future<Map<String, dynamic>> Function(), String)>[
        (() => AuthService.sendOtpViaEmail(otpId: 'otp-1'),
            '/api/v1/auth/send-otp-via-email/'),
        (() => AuthService.sendOtpViaWhatsApp(otpId: 'otp-1'),
            '/api/v1/auth/send-otp-via-whatsapp/'),
      ]) {
        late Map<String, dynamic> sent;
        final r = await http.runWithClient(
          call,
          () => MockClient((req) async {
            expect(req.method, 'POST', reason: path);
            expect(req.url.path, path);
            sent = jsonDecode(req.body) as Map<String, dynamic>;
            return _ok(_phoneData(status: 'sent', emailSent: true));
          }),
        );
        expect(sent, {'otp_id': 'otp-1'}, reason: path);
        expect(r['success'], isTrue, reason: path);
        expect((r['delivery'] as OtpDelivery).emailSent, isTrue, reason: path);
      }
    });

    test('TC_A_FB_009 — every new error code reads plainly and hides the code',
        () async {
      final cases = <(String, int, String)>[
        ('OTP_NOT_FOUND', 404, 'no longer valid'),
        ('OTP_NOT_ACTIVE', 409, 'already been used or replaced'),
        ('FALLBACK_EMAIL_UNAVAILABLE', 409, 'no email address on file'),
        ('EMAIL_ALREADY_SENT', 409, 'already been emailed'),
        ('ALTERNATE_NOT_AVAILABLE', 409, 'Resend'),
        ('VERIFIED_PHONE_UNAVAILABLE', 409, 'no verified phone number'),
        ('WHATSAPP_ALREADY_SENT', 409, 'already been sent on WhatsApp'),
        ('RATE_LIMIT_EXCEEDED', 429, 'Too many requests'),
      ];
      for (final (code, status, expected) in cases) {
        final r = await http.runWithClient(
          () => AuthService.sendOtpViaEmail(otpId: 'otp-1'),
          () => MockClient((_) async => _err(code, status)),
        );
        expect(r['success'], isFalse, reason: code);
        expect(r['code'], code, reason: code);
        expect(r['message'], contains(expected), reason: code);
        expect(r['message'], isNot(contains(code)), reason: code);
        expect(r['delivery'], isNull, reason: code);
      }
    });
  });

  group('OtpDelivery', () {
    test('TC_M_FB_010 — an unknown status is pending, never a failure', () {
      final d = OtpDelivery.fromJson(_phoneData(status: 'carrier_pending'))!;
      expect(d.status, OtpDeliveryStatus.unknown);
      expect(d.status.isPending, isTrue);
      expect(d.status.isSettled, isFalse);
      expect(d.needsEmailAddress, isFalse,
          reason: 'an unrecognised state must not be reported as failed');
    });

    test('TC_M_FB_011 — the WhatsApp option stays hidden until it is unlocked',
        () {
      final locked = OtpDelivery.fromJson(
          _emailData(available: false, resendCount: 1))!.alternate!;
      expect(locked.available, isFalse);
      expect(locked.canSendToWhatsApp, isFalse);
      expect(locked.needsPhoneLogin, isFalse);

      final noPhone = OtpDelivery.fromJson(
          _emailData(mode: 'phone_login', separateAccount: true))!.alternate!;
      expect(noPhone.canSendToWhatsApp, isFalse);
      expect(noPhone.needsPhoneLogin, isTrue);
      expect(noPhone.separateAccount, isTrue);
    });

    test('TC_M_FB_012 — no otp_id means no delivery object at all', () {
      expect(OtpDelivery.fromJson(null), isNull);
      expect(OtpDelivery.fromJson({'status': 'queued'}), isNull);
      expect(OtpDelivery.fromJson({'otp_id': '', 'status': 'queued'}), isNull);
    });
  });

  group('verification screen', () {
    testWidgets('TC_S_FB_013 — the WhatsApp screen polls and reports what is '
        'actually known', (tester) async {
      var polls = 0;
      // The poll timer is created in initState, and a timer's callback runs in
      // the zone that created it — so the whole body, not just the pumps, has
      // to sit inside runWithClient or the polls escape the mock.
      await http.runWithClient(
        () async {
          await pumpTLBApp(
            tester,
            OtpVerificationScreen(
              identifier: _phone,
              identifierType: 'phone',
              isLoginFlow: true,
              delivery: OtpDelivery.fromJson(_phoneData()),
            ),
          );
          // Accepted by WhatsApp is not delivered, so it only claims "sending".
          expect(find.text('Sending the code on WhatsApp…'), findsOneWidget);
          expect(find.text('Delivered on WhatsApp.'), findsNothing);
          expect(polls, 0);

          await tester.pump(const Duration(seconds: 3));
          await tester.pump();
          expect(polls, 1);
          expect(find.text('Delivered on WhatsApp.'), findsOneWidget);

          // Settled, so the next ticks must not spend another request.
          await tester.pump(const Duration(seconds: 6));
          expect(polls, 1, reason: 'polling stops once the state is settled');
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((req) async {
          polls++;
          expect(req.url.path, '/api/v1/auth/otp-delivery-status/');
          return _ok(_phoneData(status: 'delivered'));
        }),
      );
    });

    testWidgets('TC_S_FB_014 — an unconfirmed send offers email, and sending '
        'it keeps the same code', (tester) async {
      await pumpTLBApp(
        tester,
        OtpVerificationScreen(
          identifier: _phone,
          identifierType: 'phone',
          isLoginFlow: true,
          delivery: OtpDelivery.fromJson(_phoneData(status: 'unconfirmed')),
        ),
      );
      expect(find.text("WhatsApp hasn't confirmed delivery yet."),
          findsOneWidget);
      final button = find.text('Send the code by email instead');
      expect(button, findsOneWidget);

      late Uri url;
      await http.runWithClient(
        () async {
          await tester.tap(button);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        },
        () => MockClient((req) async {
          url = req.url;
          return _ok(_phoneData(status: 'unconfirmed', emailSent: true));
        }),
      );
      expect(url.path, '/api/v1/auth/send-otp-via-email/',
          reason: 'the same code is re-sent, not a new one requested');
      expect(find.text('Code sent to u***@example.com'), findsOneWidget);
      // One switch per code: the offer is gone, and the screen says why.
      expect(button, findsNothing);
      expect(
          find.textContaining("also emailed the code to u***@example.com"),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_FB_015 — a WhatsApp failure shows the email the server '
        'sent on its own, and offers nothing more', (tester) async {
      await pumpTLBApp(
        tester,
        OtpVerificationScreen(
          identifier: _phone,
          identifierType: 'phone',
          isLoginFlow: true,
          delivery: OtpDelivery.fromJson(
              _phoneData(status: 'failed', emailSent: true)),
        ),
      );
      expect(
          find.textContaining(
              "WhatsApp couldn't deliver the code, so we've emailed it to "
              "u***@example.com"),
          findsOneWidget);
      expect(find.text('Send the code by email instead'), findsNothing);
      expect(find.text('Get the code by email'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_FB_016 — a failure with no address asks for one and '
        'starts a new code with it', (tester) async {
      Map<String, dynamic>? sent;
      // The dialog is awaited mid-handler, so the request that follows it
      // resumes in the zone the handler started in — the whole body again.
      await http.runWithClient(
        () async {
          await pumpTLBApp(
            tester,
            OtpVerificationScreen(
              identifier: _phone,
              identifierType: 'phone',
              isLoginFlow: true,
              delivery: OtpDelivery.fromJson(_phoneData(
                  status: 'failed', fallbackAvailable: false, emailHint: null)),
            ),
          );
          expect(
              find.text("WhatsApp couldn't deliver the code."), findsOneWidget);
          await tester.tap(find.text('Get the code by email'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text("Couldn't send on WhatsApp"), findsOneWidget);

          // A malformed address never reaches the server.
          await tester.enterText(find.byType(TextField).last, 'not-an-email');
          await tester.tap(find.text('Send code'));
          await tester.pump();
          expect(
              find.text('Please enter a valid email address'), findsOneWidget);
          expect(sent, isNull);

          await tester.enterText(find.byType(TextField).last, _email);
          await tester.tap(find.text('Send code'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          // fallback_email is only read by request-otp, so this is a NEW code
          // — and verify still uses the phone number the flow started with.
          expect(sent!['fallback_email'], _email);
          expect(sent!['identifier'], _phone);
          expect(sent!['identifier_type'], 'phone');
          expect(find.text('Sending a new code to $_email'), findsOneWidget);
          await tester.pump(const Duration(seconds: 6));
          await tester.pumpWidget(const SizedBox());
        },
        // Dispatched by path, not asserted: the new code starts its own
        // delivery polling, and those ticks are not what this test is about.
        () => MockClient((req) async {
          if (req.url.path == '/api/v1/auth/request-otp/') {
            sent = jsonDecode(req.body) as Map<String, dynamic>;
          }
          return _ok(_phoneData(otpId: 'otp-2'));
        }),
      );
    });

    testWidgets('TC_S_FB_017 — an email login offers WhatsApp only once the '
        'server unlocks it, and never polls', (tester) async {
      var requests = 0;
      Uri? url;
      await http.runWithClient(
        () async {
          await pumpTLBApp(
            tester,
            OtpVerificationScreen(
              identifier: _email,
              isLoginFlow: true,
              delivery: OtpDelivery.fromJson(_emailData(available: false)),
            ),
          );
          expect(
              find.text('Not there? Check your spam folder.'), findsOneWidget);
          expect(
              find.textContaining('Send the code on WhatsApp'), findsNothing);
          await tester.pump(const Duration(seconds: 9));
          expect(requests, 0,
              reason: 'an email send has no delivery state to poll');

          // A fresh push, not a rebuild: the screen reads `delivery` in
          // initState, so the State has to be a new one.
          await tester.pumpWidget(const SizedBox());

          // Unlocked after the third resend.
          await pumpTLBApp(
            tester,
            OtpVerificationScreen(
              identifier: _email,
              isLoginFlow: true,
              delivery: OtpDelivery.fromJson(_emailData()),
            ),
          );
          final button =
              find.text('Send the code on WhatsApp to +91********10');
          expect(button, findsOneWidget);

          await tester.tap(button);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(url?.path, '/api/v1/auth/send-otp-via-whatsapp/');
          expect(find.text('Code sent on WhatsApp to +91********10'),
              findsOneWidget);
          expect(button, findsNothing, reason: 'one switch per code');
          await tester.pump(const Duration(seconds: 6));
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((req) async {
          requests++;
          url = req.url;
          return _ok(_emailData());
        }),
      );
    });

    testWidgets('TC_S_FB_018 — without a verified phone the email login is '
        'warned before being sent to a phone sign-in', (tester) async {
      await pumpTLBApp(
        tester,
        OtpVerificationScreen(
          identifier: _email,
          isLoginFlow: true,
          delivery: OtpDelivery.fromJson(
              _emailData(mode: 'phone_login', separateAccount: true)),
        ),
      );
      await tester.tap(find.text('Sign in with WhatsApp instead'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in with WhatsApp instead?'), findsOneWidget);
      expect(find.textContaining('may be a different account'), findsOneWidget);
      // Backing out leaves the code on screen usable.
      await tester.tap(find.text('Stay here'));
      await tester.pumpAndSettle();
      expect(find.text('OTP Verification'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('TC_S_FB_019 — "verify later" has no delivery tracking and no '
        'fallback', (tester) async {
      var requests = 0;
      await http.runWithClient(
        () async {
          await pumpTLBApp(
            tester,
            OtpVerificationScreen(
              identifier: _phone,
              identifierType: 'phone',
              // A contact-verification flow: different endpoints, no otp_id.
              verifyOverride: (_) async => {'success': false, 'message': 'no'},
              resendOverride: () async => {'success': true},
              delivery: OtpDelivery.fromJson(_phoneData(status: 'unconfirmed')),
            ),
          );
          expect(find.text('Send the code by email instead'), findsNothing);
          await tester.pump(const Duration(seconds: 9));
          expect(requests, 0);
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((_) async {
          requests++;
          return _ok(_phoneData());
        }),
      );
    });
  });

  group('whatsapp auth card', () {
    testWidgets('TC_S_FB_020 — the optional email is offered as the fallback, '
        'and the delivery state reaches the code screen', (tester) async {
      Map<String, dynamic>? sent;
      await http.runWithClient(
        () async {
          await pumpTLBApp(tester, const WhatsAppSignupScreen());
          await tester.enterText(find.byType(TextField).first, '9876543210');
          await tester.enterText(find.byType(TextField).last, _email);
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));

          // A WhatsApp signup has no account email, so this is the only way
          // the server can be given one to fall back to.
          expect(sent!['fallback_email'], _email);
          expect(sent!['purpose'], 'register');
          expect(sent!['identifier'], _phone);
          // Threaded through to the verification screen, which is now
          // tracking the send rather than guessing.
          expect(find.text('WhatsApp Verification'), findsOneWidget);
          expect(
              find.text('Sending the code on WhatsApp…'), findsOneWidget);
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((req) async {
          if (req.url.path == '/api/v1/auth/request-otp/') {
            sent = jsonDecode(req.body) as Map<String, dynamic>;
          }
          return _ok(_phoneData());
        }),
      );
    });

    testWidgets('TC_S_FB_021 — a typo is caught here, and a blank field '
        'leaves the request as it was', (tester) async {
      var requests = 0;
      Map<String, dynamic>? sent;
      await http.runWithClient(
        () async {
          await pumpTLBApp(tester, const WhatsAppLoginScreen());
          await tester.enterText(find.byType(TextField).first, '9876543210');
          await tester.enterText(find.byType(TextField).last, 'not-an-email');
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          // Sending a typo would put the fallback nowhere on the one send
          // that needed it, so nothing is sent at all.
          expect(requests, 0);
          expect(
              find.text('Please enter a valid email address'), findsOneWidget);
          expect(find.text('WhatsApp Verification'), findsNothing);

          // Let the snackbar clear before tapping again.
          await tester.pump(const Duration(seconds: 5));
          await tester.enterText(find.byType(TextField).last, '   ');
          await tester.tap(find.text('Send OTP on WhatsApp'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          // No address offered, so the body is byte-for-byte what it was
          // before the fallback existed — an older server still accepts it.
          expect(sent, {
            'identifier': _phone,
            'identifier_type': 'phone',
            'purpose': 'login',
          });
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((req) async {
          if (req.url.path == '/api/v1/auth/request-otp/') {
            requests++;
            sent = jsonDecode(req.body) as Map<String, dynamic>;
          }
          return _ok(_phoneData());
        }),
      );
    });
  });
}
