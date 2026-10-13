import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:tlb_mobile_ui/providers/auth_state.dart';
import 'package:tlb_mobile_ui/screens/profile_screen.dart';

import '../helpers/test_setup.dart';

/// Taking a profile photo. Every failure here used to surface as "Could not
/// open the picker", which named neither the cause nor the cure — a customer
/// who had denied camera access had no way to learn that was why.
///
/// Android is deliberately not asked for camera permission at all: the app
/// declares none, so `image_picker` hands the capture to the system camera
/// app, which asks for its own. iOS does prompt, and reports a refusal as
/// `camera_access_denied`, which is what these tests drive.
void main() {
  const channel = MethodChannel('plugins.flutter.io/image_picker');
  late List<MethodCall> calls;

  /// Replies to the picker channel with [onPick], standing in for the
  /// platform. Returning null is a cancelled pick.
  void mockPicker(Future<Object?> Function(MethodCall call) onPick) {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
      calls.add(call);
      return onPick(call);
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
  }

  setUp(() {
    AuthState.userName.value = 'John Doe';
    AuthState.userEmail = 'john@example.com';
    AuthState.avatarUrl.value = null;
    AuthState.userData = {
      'profile': {'first_name': 'John', 'last_name': 'Doe'}
    };
  });

  /// Opens the avatar sheet from the profile header and taps [option].
  Future<void> tapAvatarOption(WidgetTester tester, String option) async {
    await pumpTLBApp(tester, const ProfileScreen());
    // The camera badge on the avatar — the only one until the sheet opens.
    await tester.tap(find.byIcon(Icons.camera_alt_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Take a Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    await tester.tap(find.text(option));
    await tester.pumpAndSettle();
  }

  testWidgets('TC_S_AV_001 — "Take a Photo" asks the camera, not the gallery',
      (tester) async {
    await mockNetworkImages(() async {
      // A cancelled capture: the screen must simply carry on.
      mockPicker((_) async => null);
      await tapAvatarOption(tester, 'Take a Photo');

      expect(calls.single.method, 'pickImage');
      // ImageSource.camera is index 0 on the wire; gallery is 1.
      expect(calls.single.arguments['source'], 0);
      expect(AuthState.avatarUrl.value, isNull);
      expect(find.textContaining('Could not'), findsNothing);
      expect(find.textContaining("Couldn't"), findsNothing);
    });
  });

  testWidgets('TC_S_AV_002 — a blocked camera says so and offers Settings',
      (tester) async {
    await mockNetworkImages(() async {
      mockPicker((_) async => throw PlatformException(
            code: 'camera_access_denied',
            message: 'The user did not allow camera access.',
          ));
      await tapAvatarOption(tester, 'Take a Photo');

      expect(find.text('Camera access needed'), findsOneWidget);
      expect(find.textContaining('app settings'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      // The old catch-all said nothing about which permission, or where.
      expect(find.textContaining('Could not open the picker'), findsNothing);

      // Dismissing leaves the profile intact.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(AuthState.avatarUrl.value, isNull);
      expect(find.text('My Profile'), findsOneWidget);
    });
  });

  testWidgets('TC_S_AV_003 — a denied photo library is named separately',
      (tester) async {
    await mockNetworkImages(() async {
      mockPicker((_) async => throw PlatformException(
            code: 'photo_access_denied',
            message: 'The user did not allow photo access.',
          ));
      await tapAvatarOption(tester, 'Choose from Gallery');

      expect(calls.single.arguments['source'], 1, reason: 'gallery');
      expect(find.text('Photo access needed'), findsOneWidget);
      expect(find.text('Camera access needed'), findsNothing);
    });
  });

  testWidgets('TC_S_AV_004 — a device with no camera is told plainly, with no '
      'Settings dead end', (tester) async {
    await mockNetworkImages(() async {
      mockPicker((_) async =>
          throw PlatformException(code: 'no_available_camera'));
      await tapAvatarOption(tester, 'Take a Photo');

      expect(find.text('No camera is available on this device.'),
          findsOneWidget);
      // No permission to grant, so no Settings prompt.
      expect(find.text('Open Settings'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
    });
  });

  testWidgets('TC_S_AV_005 — an unexpected failure names the camera it could '
      'not open', (tester) async {
    await mockNetworkImages(() async {
      mockPicker((_) async => throw PlatformException(code: 'already_active'));
      await tapAvatarOption(tester, 'Take a Photo');

      expect(find.text("Couldn't open the camera. Please try again."),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
