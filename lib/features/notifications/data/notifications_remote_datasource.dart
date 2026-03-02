import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationsRemoteDatasource {
  Future<void> initialize();
  Future<void> subscribeToAuction(String auctionId);
  Future<void> unsubscribeFromAuction(String auctionId);
  Future<String?> getToken();
  Future<void> saveTokenToFirestore(String userId, String token);
}

class NotificationsRemoteDatasourceImpl implements NotificationsRemoteDatasource {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  void _showLocalNotification(RemoteMessage msg) {
    final n = msg.notification;
    if (n == null) return;
    _local.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails('auction_alerts', 'Veiling Alarmen',
            importance: Importance.max, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
      payload: msg.data['auctionId'],
    );
  }

  @override
  Future<void> subscribeToAuction(String auctionId) =>
      _messaging.subscribeToTopic('auction_alarm_$auctionId');

  @override
  Future<void> unsubscribeFromAuction(String auctionId) =>
      _messaging.unsubscribeFromTopic('auction_alarm_$auctionId');

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<void> saveTokenToFirestore(String userId, String token) async {
    // Save FCM token to Firestore user document
  }
}
