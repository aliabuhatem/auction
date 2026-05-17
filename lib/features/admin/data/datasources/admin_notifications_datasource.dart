import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_notification_entity.dart';

class AdminNotificationsDatasource {
  final FirebaseFirestore _db;
  final FirebaseAuth      _auth;

  AdminNotificationsDatasource({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db   = db   ?? FirebaseFirestore.instance,
        _auth  = auth ?? FirebaseAuth.instance;

  Future<List<AdminNotificationEntity>> getNotifications({int limit = 100}) async {
    try {
      final snap = await _db
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map(_mapNotification).toList();
    } catch (e) {
      throw Exception('Fout bij ophalen meldingen: $e');
    }
  }

  Future<void> sendNotification({
    required String    title,
    required String    body,
    required bool      toAll,
    String?            targetUserId,
    DateTime?          scheduledFor,
  }) async {
    try {
      await _db.collection('notifications').add({
        'title':        title,
        'body':         body,
        'target':       toAll ? 'all' : 'specific',
        'targetUserId': targetUserId,
        'status':       'scheduled',
        'scheduledFor': scheduledFor?.toIso8601String(),
        'sentBy':       _auth.currentUser?.uid ?? '',
        'sentCount':    0,
        'createdAt':    DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Melding verzenden mislukt: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _db.collection('notifications').doc(id).delete();
    } catch (e) {
      throw Exception('Verwijderen mislukt: $e');
    }
  }

  AdminNotificationEntity _mapNotification(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AdminNotificationEntity(
      id:           doc.id,
      title:        d['title']        as String? ?? '',
      body:         d['body']         as String? ?? '',
      target:       d['target']       as String? ?? 'all',
      targetUserId: d['targetUserId'] as String?,
      status:       d['status']       as String? ?? 'scheduled',
      sentCount:    (d['sentCount']   as num?)?.toInt() ?? 0,
      sentBy:       d['sentBy']       as String? ?? '',
      createdAt:    _ts(d['createdAt']),
      scheduledFor: _tsOpt(d['scheduledFor']),
    );
  }

  static DateTime _ts(dynamic v, [DateTime? fallback]) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
    return fallback ?? DateTime.now();
  }

  static DateTime? _tsOpt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v);
    return null;
  }
}
