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

    // Run queries in parallel
    final results = await Future.wait([
      _db.collection('auctions').count().get(),
      _db.collection('auctions').where('status', isEqualTo: 'live').count().get(),
      _db.collection('users').count().get(),
      _db.collection('bids')
          .where('createdAt', isGreaterThanOrEqualTo: todayStart.toIso8601String())
          .count().get(),
      _db.collection('orders').where('status', isEqualTo: 'pending').count().get(),
    ]);

    final totalAuctions   = results[0].count ?? 0;
    final liveAuctions    = results[1].count ?? 0;
    final totalUsers      = results[2].count ?? 0;
    final todayBids       = results[3].count ?? 0;
    final pendingPayments = results[4].count ?? 0;

    // Revenue — sum of paid orders
    double totalRevenue = 0;
    final paidOrders = await _db.collection('orders')
        .where('status', isEqualTo: 'paid')
        .get();
    for (final doc in paidOrders.docs) {
      totalRevenue += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }

    // Recent bids
    final recentSnap = await _db.collection('bids')
        .orderBy('createdAt', descending: true)
        .limit(8)
        .get();

    final recentBids = recentSnap.docs.map((d) {
      final data = d.data();
      return RecentBidItem(
        userId:       data['userId']       ?? '',
        userName:     data['userName']     ?? 'Onbekend',
        auctionId:    data['auctionId']    ?? '',
        auctionTitle: data['auctionTitle'] ?? '',
        amount:       (data['amount'] as num?)?.toDouble() ?? 0,
        createdAt:    DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();

    // Ending soon
    final endSnap = await _db.collection('auctions')
        .where('status', isEqualTo: 'live')
        .orderBy('endsAt')
        .limit(5)
        .get();

    final endingSoon = endSnap.docs.map((d) {
      final data = d.data();
      return EndingSoonItem(
        id:         d.id,
        title:      data['title']      ?? '',
        bidCount:   (data['bidCount']  as num?)?.toInt() ?? 0,
        currentBid: (data['currentBid'] as num?)?.toDouble() ?? 0,
        endsAt:     DateTime.tryParse(data['endsAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();

    // 7-day bid chart — last 7 days
    final bidChart = <ChartPoint>[];
    final days     = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
    for (int i = 6; i >= 0; i--) {
      final day   = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day).toIso8601String();
      final end   = DateTime(day.year, day.month, day.day, 23, 59).toIso8601String();
      final snap  = await _db.collection('bids')
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .count().get();
      bidChart.add(ChartPoint(days[day.weekday - 1], (snap.count ?? 0).toDouble()));
    }

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
