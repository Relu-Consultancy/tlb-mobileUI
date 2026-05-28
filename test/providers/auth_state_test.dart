import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/services/token_storage.dart';

void main() {
  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    AuthState.logout();
    await TokenStorage.clearTokens();
  });

  group('AuthState Tests', () {
    test('login updates properties and tokens correctly', () async {
      final user = {
        'email': 'test@example.com',
        'profile': {
          'first_name': 'Test',
          'last_name': 'User',
          'avatar_url': 'http://example.com/avatar.png'
        }
      };

      AuthState.login(
        access: 'access123',
        refresh: 'refresh123',
        user: user,
      );

      // Verify AuthState static properties
      expect(AuthState.isLoggedIn.value, isTrue);
      expect(AuthState.userEmail, 'test@example.com');
      expect(AuthState.userName.value, 'Test User');
      expect(AuthState.avatarUrl.value, 'http://example.com/avatar.png');
      expect(AuthState.accessToken, 'access123');
      expect(AuthState.refreshToken, 'refresh123');
      expect(AuthState.firstName, 'Test');
      expect(AuthState.isProfileComplete, isTrue);

      // Verify tokens were stored
      final tokens = await TokenStorage.loadTokens();
      expect(tokens['access'], 'access123');
      expect(tokens['refresh'], 'refresh123');
      
      final storedUser = jsonDecode(tokens['user_json']!);
      expect(storedUser['email'], 'test@example.com');
    });

    test('updateUserProfile syncs state and storage', () async {
      AuthState.login(access: 'token', refresh: 'token', user: {'email': 'old@example.com'});

      final updatedUser = {
        'email': 'new@example.com',
        'profile': {
          'first_name': 'New',
          'last_name': 'Name',
        }
      };

      AuthState.updateUserProfile(updatedUser);

      expect(AuthState.userName.value, 'New Name');
      expect(AuthState.isProfileComplete, isTrue);

      final tokens = await TokenStorage.loadTokens();
      final storedUser = jsonDecode(tokens['user_json']!);
      expect(storedUser['email'], 'new@example.com');
    });

    test('logout clears state and storage', () async {
      AuthState.login(access: 'token', refresh: 'token', user: {'email': 'test@example.com'});
      expect(AuthState.isLoggedIn.value, isTrue);

      AuthState.logout();

      expect(AuthState.isLoggedIn.value, isFalse);
      expect(AuthState.userEmail, isNull);
      expect(AuthState.accessToken, isNull);

      final tokens = await TokenStorage.loadTokens();
      expect(tokens['access'], isNull);
    });
  });

  // ── Session 44 regression: email-in-greeting bug ─────────────────────────
  group('AuthState.login userName resolution (Session 44)', () {
    test('uses first + last name when profile is populated', () {
      AuthState.login(
        user: {
          'email': 'visheshsrivastava@reluconsultancy.in',
          'profile': {'first_name': 'Vishesh', 'last_name': 'Srivastava'},
        },
      );
      expect(AuthState.userName.value, 'Vishesh Srivastava');
      expect(AuthState.firstName, 'Vishesh');
    });

    test('falls back to null (not email) when profile is absent', () {
      // The home header reads userName and shows "Hello There" when null.
      // Before the fix, this returned the email and the header showed
      // "Hello visheshsrivastava@reluconsultancy.in".
      AuthState.login(
        user: {'email': 'visheshsrivastava@reluconsultancy.in'},
      );
      expect(AuthState.userName.value, isNull);
      expect(AuthState.firstName, 'User');
    });

    test('falls back to null when profile has empty first/last', () {
      AuthState.login(
        user: {
          'email': 'visheshsrivastava@reluconsultancy.in',
          'profile': {'first_name': '', 'last_name': ''},
        },
      );
      expect(AuthState.userName.value, isNull);
    });

    test('explicit name parameter wins over profile', () {
      AuthState.login(
        name: 'Override Name',
        user: {
          'email': 'a@b.com',
          'profile': {'first_name': 'Profile', 'last_name': 'Name'},
        },
      );
      expect(AuthState.userName.value, 'Override Name');
    });

    test('userEmail is still populated from email field', () {
      // The email itself is still stored — just not used as a greeting.
      AuthState.login(
        user: {'email': 'visheshsrivastava@reluconsultancy.in'},
      );
      expect(AuthState.userEmail, 'visheshsrivastava@reluconsultancy.in');
    });
  });
}
