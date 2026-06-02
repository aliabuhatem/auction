import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../../../core/errors/exceptions.dart';

class AdminRemoteDatasource {
  final FirebaseAuth      _auth;
  final FirebaseFirestore  _db;

  AdminRemoteDatasource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db   = db   ?? FirebaseFirestore.instance;

  // ── Auth ────────────────────────────────────────────────────────────────────

  Future<AdminUserEntity> loginAdmin(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      final uid  = cred.user!.uid;
      final snap = await _db.collection('admins').doc(uid).get();

      if (!snap.exists) {
        await _auth.signOut();
        throw const AuthException('Geen beheerderstoegang voor dit account.');
      }

      final data = snap.data()!;
      if (data['isActive'] == false) {
        await _auth.signOut();
        throw const AuthException('Dit beheerdersaccount is gedeactiveerd.');
      }

      return _mapAdmin(uid, data);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  Future<void> logoutAdmin() => _auth.signOut();

  Stream<AdminUserEntity?> watchCurrentAdmin() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final snap = await _db.collection('admins').doc(user.uid).get();
      if (!snap.exists || snap.data()?['isActive'] == false) {
        await _auth.signOut();
        return null;
      }
      return _mapAdmin(user.uid, snap.data()!);
    });
  }

  Future<AdminUserEntity?> getCurrentAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _db.collection('admins').doc(user.uid).get();
    if (!snap.exists) return null;
    return _mapAdmin(user.uid, snap.data()!);
  }

  // ── Dashboard stats ─────────────────────────────────────────────────────────

  Future<DashboardStatsEntity> getDashboardStats() async {
    final now        = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final days       = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

    Future<int> safeCount(Query<Map<String, dynamic>> q) async {
      try { return (await q.count().get()).count ?? 0; } catch (_) { return 0; }
    }
    Future<QuerySnapshot<Map<String, dynamic>>> safeGet(
        Query<Map<String, dynamic>> q) async {
      try { return await q.get(); } catch (_) {
        return await _db.collection('_nonexistent_').limit(0).get();
      }
    }

    // All queries run in parallel — single network round trip
    final chartDays  = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final todayTs    = Timestamp.fromDate(todayStart);
    final results    = await Future.wait<dynamic>([
      safeCount(_db.collection('auctions')),                                           // 0
      safeCount(_db.collection('auctions').where('status', isEqualTo: 'live')),       // 1
      safeCount(_db.collection('users')),                                               // 2
      safeCount(_db.collection('bids').where('createdAt',
          isGreaterThanOrEqualTo: todayTs)),                                            // 3
      safeCount(_db.collection('orders').where('status', isEqualTo: 'pending')),       // 4
      safeGet(_db.collection('orders').where('status', isEqualTo: 'paid').limit(500)), // 5
      safeGet(_db.collection('bids').orderBy('createdAt', descending: true).limit(8)), // 6
      safeGet(_db.collection('auctions')
          .where('status', isEqualTo: 'live').orderBy('endsAt').limit(5)),              // 7
      Future.wait(chartDays.map((day) {
        final s = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
        final e = Timestamp.fromDate(DateTime(day.year, day.month, day.day, 23, 59, 59));
        return safeCount(_db.collection('bids')
            .where('createdAt', isGreaterThanOrEqualTo: s)
            .where('createdAt', isLessThanOrEqualTo: e));
      })),                                                                               // 8
    ]);

    final totalAuctions   = results[0] as int;
    final liveAuctions    = results[1] as int;
    final totalUsers      = results[2] as int;
    final todayBids       = results[3] as int;
    final pendingPayments = results[4] as int;
    final paidSnap        = results[5] as QuerySnapshot<Map<String, dynamic>>;
    final recentSnap      = results[6] as QuerySnapshot<Map<String, dynamic>>;
    final endSnap         = results[7] as QuerySnapshot<Map<String, dynamic>>;
    final chartCounts     = (results[8] as List).cast<int>();

    double totalRevenue = 0;
    for (final doc in paidSnap.docs) {
      totalRevenue += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }

    final recentBids = recentSnap.docs.map((d) {
      final data = d.data();
      return RecentBidItem(
        userId:       data['userId']       ?? '',
        userName:     data['userName']     ?? 'Onbekend',
        auctionId:    data['auctionId']    ?? '',
        auctionTitle: data['auctionTitle'] ?? '',
        amount:       (data['amount'] as num?)?.toDouble() ?? 0,
        createdAt:    _ts(data['createdAt']),
      );
    }).toList();

    final endingSoon = endSnap.docs.map((d) {
      final data = d.data();
      return EndingSoonItem(
        id:         d.id,
        title:      data['title']       ?? '',
        bidCount:   (data['bidCount']   as num?)?.toInt()    ?? 0,
        currentBid: (data['currentBid'] as num?)?.toDouble() ?? 0,
        endsAt:     _ts(data['endsAt']),
      );
    }).toList();

    final bidChart = List.generate(7, (i) =>
        ChartPoint(days[chartDays[i].weekday - 1], chartCounts[i].toDouble()));

    return DashboardStatsEntity(
      totalAuctions:   totalAuctions,
      liveAuctions:    liveAuctions,
      totalUsers:      totalUsers,
      todayBids:       todayBids,
      totalRevenue:    totalRevenue,
      pendingPayments: pendingPayments,
      bidChart:        bidChart,
      revenueChart:    [],
      recentBids:      recentBids,
      endingSoon:      endingSoon,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static DateTime _ts(dynamic v, [DateTime? fallback]) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
    return fallback ?? DateTime.now();
  }

  AdminUserEntity _mapAdmin(String uid, Map<String, dynamic> data) {
    return AdminUserEntity(
      id:          uid,
      email:       data['email']       ?? '',
      displayName: data['displayName'] ?? '',
      role:        AdminRoleX.fromString(data['role'] as String?),
      branch:      data['branch']      as String?,
      isActive:    data['isActive']    ?? true,
    );
  }
}
