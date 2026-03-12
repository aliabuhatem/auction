
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> subscribeToAuctionAlarm(String auctionId) async {
    await _messaging.subscribeToTopic('auction_alarm_$auctionId');
  }

  Future<void> unsubscribeFromAuctionAlarm(String auctionId) async {
    await _messaging.unsubscribeFromTopic('auction_alarm_$auctionId');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'auction_alerts',
          'Veiling alarmen',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['auctionId'],
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final auctionId = message.data['auctionId'];
    if (auctionId != null) {
      // Navigate to auction detail - use a global navigator key
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to auction detail using the payload (auctionId)
  }

  Future<String?> getToken() => _messaging.getToken();
}