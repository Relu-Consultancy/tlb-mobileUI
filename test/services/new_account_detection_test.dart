import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tlb_mobile_ui/services/auth_service.dart';

/// bug_login_002 — a brand-new email signed in with "Continue with Google" was
/// greeted "Welcome Back". google-login creates the account but sends no
/// "new user" flag (only tokens + `user`, per the backend's GoogleLoginView),
/// and the app read the missing flag as "returning". The profile now decides:
/// an account this sign-in just created has no name yet.

/// google-login's 200, shaped exactly as the backend builds it
/// (`_build_token_response`): no is_new_user anywhere.
http.Response _googleLoginOk() => http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'access_token': 'access-abc',
          'refresh_token': 'refresh-abc',
          'user': {
            'id': '3d52dbe8-dfa8-4966-b21c-aa55bd4d8a3e',
            'email': 'new.parent@gmail.com',
            'role': 'customer',
            'auth_provider': 'google',
            'is_verified': true,
            'last_login': '2026-10-07T16:30:00Z',
          },
        },
        'error': null,
      }),
      200,
    );

/// GET /customer/profile/ — the backend creates an empty one on first read.
http.Response _profile({String firstName = '', bool completed = false}) =>
    http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'id': 24,
          'first_name': firstName,
          'last_name': '',
          'is_completed': completed,
        },
        'error': null,
      }),
      200,
    );

Future<bool> _signInAndDetect(http.Response Function() profile) =>
    http.runWithClient(
      () async {
        final result = await AuthService.googleSignIn(idToken: 'firebase-id');
        expect(result['success'], isTrue);
        return AuthService.isNewAccount(result);
      },
      () => MockClient((req) async {
        if (req.url.path.endsWith('/auth/google-login/')) {
          return _googleLoginOk();
        }
        if (req.url.path.endsWith('/customer/profile/')) {
          expect(req.headers['Authorization'], 'Bearer access-abc');
          return profile();
        }
        return http.Response('', 404);
      }),
    );

void main() {
  group('AuthService.isNewAccount', () {
    test(
        'TC_A_NEW_001 — a brand-new Google account (bug_login_002) is new, '
        'though google-login sends no flag', () async {
      expect(await _signInAndDetect(_profile), isTrue);
    });

    test('TC_A_NEW_002 — a returning customer is not new', () async {
      expect(await _signInAndDetect(() => _profile(firstName: 'Bit')), isFalse);
      // is_completed alone is not trusted to mean "new": live accounts that
      // finished onboarding still carry false.
      expect(
        await _signInAndDetect(
            () => _profile(firstName: 'Bit', completed: false)),
        isFalse,
      );
    });

    test('TC_A_NEW_003 — a flag, if the backend adds one, is honoured as is',
        () async {
      var requests = 0;
      final isNew = await http.runWithClient(
        () => AuthService.isNewAccount({
          'success': true,
          'access': 'access-abc',
          'is_new_user': true,
        }),
        () => MockClient((_) async {
          requests++;
          return _profile(firstName: 'Bit');
        }),
      );
      expect(isNew, isTrue);
      expect(requests, 0, reason: 'no profile check needed');
    });

    test(
        'TC_A_NEW_004 — if the profile cannot be read, a returning customer is '
        'not pushed back through signup', () async {
      expect(
          await _signInAndDetect(() => http.Response('oops', 500)), isFalse);
      expect(await AuthService.isNewAccount({'success': true}), isFalse);
    });
  });
}
