import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../providers/auth_state.dart';
import '../providers/notifications_state.dart';
import '../screens/notification_screen.dart';
import 'notification_service.dart';

/// Background isolate handler for FCM messages received while the app is
/// terminated or backgrounded. Must be a top-level / static function annotated
/// with `@pragma('vm:entry-point')` so the Flutter engine can find it.
///
/// When the backend sends a *notification* payload, Android/iOS display it in
/// the tray automatically — nothing to do here. We only need this registered so
/// data-only messages don't get dropped.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally light: showing a local notification from a background
  // isolate needs its own plugin init, and the common case (notification
  // payload) is already auto-displayed by the OS. Kept as a no-op hook.
}

/// Bridges server/push + in-app notifications to the device's system tray.
///
/// - **FCM** delivers real push (works when the app is closed) once the backend
///   stores the device token and sends messages.
/// - **flutter_local_notifications** renders foreground pushes (FCM doesn't
///   auto-show those on Android) and mirrors polled in-app notifications.
class PushNotifications {
  PushNotifications._();

  /// Attach to [MaterialApp.navigatorKey] so taps on a notification can route
  /// to the in-app notification screen from anywhere.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tlb_default_channel',
    'General Notifications',
    description: 'Event updates, bookings and announcements',
    importance: Importance.high,
  );

  static bool _initialized = false;
  static int _idSeed = 0;

  /// One-time setup: local-notification plugin + channel, OS permission, and
  /// the FCM foreground / tap listeners. Safe to call more than once.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ── Local notifications ────────────────────────────────────────────────
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (resp) => _openNotifications(),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ── FCM (real push) ────────────────────────────────────────────────────
    // Entirely guarded: if Firebase didn't initialise, local notifications (set
    // up above) must still work — the polled-item tray mirror depends only on
    // the local plugin, never on FCM.
    try {
      // Permission (Android 13+ POST_NOTIFICATIONS prompt + iOS).
      await FirebaseMessaging.instance.requestPermission();

      // Show foreground pushes ourselves (Android suppresses them otherwise).
      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        final title =
            n?.title ?? message.data['title'] as String? ?? 'Notification';
        final body = n?.body ?? message.data['body'] as String? ?? '';
        if (title.isEmpty && body.isEmpty) return;
        showLocal(title: title, body: body, payload: 'fcm');
        // Keep the bell badge fresh.
        NotificationsState.refreshFromApi();
      });

      // Tapping a push that opened / resumed the app → in-app notifications.
      FirebaseMessaging.onMessageOpenedApp.listen((_) => _openNotifications());
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) {
        // Defer until the navigator is mounted.
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _openNotifications());
      }

      // Re-register whenever FCM rotates the token.
      FirebaseMessaging.instance.onTokenRefresh.listen((_) => registerToken());
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] FCM setup skipped: $e');
    }
  }

  /// Sends the device's FCM token to the backend so it can target this device
  /// with push. No-op when logged out or offline.
  static Future<void> registerToken() async {
    try {
      final authToken = AuthState.accessToken;
      if (authToken == null || authToken.isEmpty) return;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;
      await NotificationService.registerDeviceToken(
        token: authToken,
        fcmToken: fcmToken,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] registerToken failed: $e');
    }
  }

  /// Renders a single notification in the system tray.
  static Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) await init();
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _local.show(
      id: _idSeed++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static void _openNotifications() {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
  }
}
