import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user_entity.dart';

class AdminUsersDatasource {
  final FirebaseFirestore _db;

  AdminUsersDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<AppUserEntity>> getUsers({
    String? search,
    bool?   isActive,
    int     limit = 200,
  }) async {
    try {
      final snap = await _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      var users = snap.docs.map(_mapUser).toList();

      if (isActive != null) {
        users = users.where((u) => u.isActive == isActive).toList();
      }

      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        users = users
            .where((u) =>
                u.displayName.toLowerCase().contains(s) ||
                u.email.toLowerCase().contains(s))
            .toList();
      }

      return users;
    } catch (e) {
      throw Exception('Fout bij ophalen gebruikers: $e');
    }
  }

  Future<UserStatsEntity> getUserStats() async {
    try {
      final now        = DateTime.now();
      final todayStart = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
      final weekStart  = Timestamp.fromDate(now.subtract(const Duration(days: 7)));

      final results = await Future.wait<AggregateQuerySnapshot>([
        _db.collection('users').count().get(),
        _db.collection('users')
            .where('createdAt', isGreaterThanOrEqualTo: todayStart)
            .count()
            .get(),
        _db.collection('users')
            .where('createdAt', isGreaterThanOrEqualTo: weekStart)
            .count()
            .get(),
      ]);

      return UserStatsEntity(
        totalUsers:  results[0].count ?? 0,
        newToday:    results[1].count ?? 0,
        newThisWeek: results[2].count ?? 0,
      );
    } catch (_) {
      return const UserStatsEntity(totalUsers: 0, newToday: 0, newThisWeek: 0);
    }
  }

  Future<void> toggleUserActive(String userId, bool isActive) async {
    await _db.collection('users').doc(userId).update({'isActive': isActive});
  }

  AppUserEntity _mapUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AppUserEntity(
      id:          doc.id,
      displayName: d['displayName'] ?? 'Onbekend',
      email:       d['email']       ?? '',
      photoUrl:    d['photoUrl']    as String?,
      phoneNumber: d['phoneNumber'] as String?,
      isActive:    d['isActive']    ?? true,
      createdAt:   _ts(d['createdAt']),
    );
  }

  static DateTime _ts(dynamic v, [DateTime? fallback]) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
    return fallback ?? DateTime.now();
  }
}
