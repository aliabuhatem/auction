// lib/features/notifications/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../app/app_router.dart';

// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in the isolate.
  // Storing the notification in Firestore so it appears in the app's feed.
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null && message.notification != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': message.notification!.title ?? '',
      'body': message.notification!.body ?? '',
      'type': message.data['type'] ?? 'info',
      'data': message.data,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'auction_alerts';
  static const _channelName = 'Veiling alarmen';

  Future<void> initialize() async {
    if (kIsWeb) {
      // On web, the background handler is the service worker
      // (web/firebase-messaging-sw.js) — the Flutter API does not apply.
      // requestPermission() and token save are fire-and-forget so they do NOT
      // block main() before runApp(); otherwise Flutter never paints its first
      // frame and the HTML loading screen stays forever.
      _messaging.requestPermission().then((_) => _saveToken()).catchError((_) {});
      _messaging.onTokenRefresh.listen((_) => _saveToken());
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      return;
    }

    // Mobile only — background handler uses a native isolate.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ── Mobile ────────────────────────────────────────────────────────────────

    // Local notifications (foreground display on mobile).
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // ask explicitly during onboarding
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotifTapped,
    );

    // Create the Android notification channel.
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Meldingen voor veilingen en biedingen',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Save/refresh FCM token.
    await _saveToken();
    _messaging.onTokenRefresh.listen((_) => _saveToken());

    // Foreground messages → show local notification.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App opened from notification tap.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched from a terminated state via notification.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  // ── FCM Token ──────────────────────────────────────────────────────────────

  Future<void> _saveToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
            {'fcmToken': token, 'platform': kIsWeb ? 'web' : 'mobile'},
            SetOptions(merge: true));
      }
    } catch (_) {
      // Token save failure is non-fatal.
    }
  }

  /// Call this after user signs in so the token is persisted immediately.
  Future<void> onUserSignedIn() => _saveToken();

  /// Call this before user signs out to clear the token.
  Future<void> onUserSignedOut() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': FieldValue.delete()});
    } catch (_) {}
  }

  // ── Topic subscriptions ───────────────────────────────────────────────────

  Future<void> subscribeToAuctionAlarm(String auctionId) =>
      _messaging.subscribeToTopic('alarm_$auctionId');

  Future<void> unsubscribeFromAuctionAlarm(String auctionId) =>
      _messaging.unsubscribeFromTopic('alarm_$auctionId');

  // ── Token getter ──────────────────────────────────────────────────────────

  Future<String?> getToken() => _messaging.getToken();

  // ── Foreground message handler ────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    // Store in Firestore for the in-app feed.
    _storeNotification(message);

    if (!kIsWeb) {
      // Show as local notification on mobile.
      _localNotifications.show(
        n.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: _buildPayload(message.data),
      );
    }
  }

  // ── Notification tap handler ──────────────────────────────────────────────

  void _handleNotificationTap(RemoteMessage message) {
    _storeNotification(message);
    _navigateFromData(message.data);
  }

  void _onLocalNotifTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    // Payload is 'type:id', e.g. 'auction:abc123' or 'order:xyz456'
    final parts = payload.split(':');
    if (parts.length < 2) return;
    _navigateFromData({'type': parts[0], 'id': parts[1]});
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final id = data['auctionId'] as String? ?? data['id'] as String? ?? '';

    switch (type) {
      case 'outbid':
      case 'alarm':
      case 'won':
        if (id.isNotEmpty) {
          appRouter.go(AppRoutes.auctionDetailPath(id));
        }
        break;
      case 'payment_reminder':
        final orderId = data['orderId'] as String? ?? id;
        if (orderId.isNotEmpty) {
          appRouter.go(AppRoutes.paymentPath(orderId));
        }
        break;
      case 'voucher':
        appRouter.go(AppRoutes.tickets);
        break;
      default:
        appRouter.go(AppRoutes.notifications);
    }
  }

  String _buildPayload(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? 'info';
    final id = data['auctionId'] as String? ??
        data['orderId'] as String? ??
        data['id'] as String? ??
        '';
    return '$type:$id';
  }

  // ── Persist notification to Firestore ─────────────────────────────────────

  Future<void> _storeNotification(RemoteMessage message) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'type': message.data['type'] ?? 'info',
        'data': message.data,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
