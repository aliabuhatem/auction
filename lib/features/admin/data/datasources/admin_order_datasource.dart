// lib/features/admin/data/datasources/admin_order_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';

class AdminOrderDatasource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AdminOrderDatasource({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ── Read ─────────────────────────────────────────────────────────────────────

  Future<List<AdminOrderEntity>> getOrders({
    OrderStatus? status,
    String? search,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _db.collection('orders').orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.firestoreValue);
      }

      final snap = await query.limit(200).get();
      var orders = snap.docs.map(_mapOrder).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        orders = orders
            .where((o) =>
                o.userName.toLowerCase().contains(q) ||
                o.auctionTitle.toLowerCase().contains(q) ||
                o.userEmail.toLowerCase().contains(q) ||
                o.shortId.toLowerCase().contains(q))
            .toList();
      }

      if (from != null) {
        orders = orders.where((o) => !o.createdAt.isBefore(from)).toList();
      }
      if (to != null) {
        final toEnd = DateTime(to.year, to.month, to.day, 23, 59, 59);
        orders = orders.where((o) => !o.createdAt.isAfter(toEnd)).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Fout bij ophalen orders: $e');
    }
  }

  Future<OrderStatsEntity> getOrderStats() async {
    try {
      final now          = DateTime.now();
      final threshold20h = Timestamp.fromDate(now.subtract(const Duration(hours: 20)));

      final results = await Future.wait([
        _db.collection('orders').where('status', isEqualTo: 'pending').count().get(),
        _db.collection('orders').where('status', isEqualTo: 'failed').count().get(),
        _db.collection('orders')
            .where('status', isEqualTo: 'pending')
            .where('createdAt', isLessThanOrEqualTo: threshold20h)
            .count()
            .get(),
        _db.collection('orders').where('status', isEqualTo: 'paid').limit(500).get(),
        _db.collection('orders').where('status', isEqualTo: 'refunded').limit(500).get(),
      ]);

      final pendingCount  = (results[0] as AggregateQuerySnapshot).count ?? 0;
      final failedCount   = (results[1] as AggregateQuerySnapshot).count ?? 0;
      final expiringCount = (results[2] as AggregateQuerySnapshot).count ?? 0;
      final paidSnap      = results[3] as QuerySnapshot<Map<String, dynamic>>;
      final refundedSnap  = results[4] as QuerySnapshot<Map<String, dynamic>>;

      final totalRevenue = paidSnap.docs.fold<double>(
          0, (s, d) => s + ((d.data()['amount'] as num?)?.toDouble() ?? 0));
      final refundedTotal = refundedSnap.docs.fold<double>(
          0, (s, d) => s + ((d.data()['amount'] as num?)?.toDouble() ?? 0));

      return OrderStatsEntity(
        totalRevenue:  totalRevenue,
        pendingCount:  pendingCount,
        failedCount:   failedCount,
        refundedTotal: refundedTotal,
        expiringCount: expiringCount,
      );
    } catch (e) {
      throw Exception('Fout bij ophalen statistieken: $e');
    }
  }

  // Last 10 days revenue chart.
  Future<List<ChartPoint>> getRevenueChart() async {
    try {
      final now    = DateTime.now();
      final labels = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

      // Parallel queries for all 10 days
      final futures = List.generate(10, (i) {
        final day   = now.subtract(Duration(days: 9 - i));
        final start = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
        final end   = Timestamp.fromDate(
            DateTime(day.year, day.month, day.day, 23, 59, 59));
        return _db
            .collection('orders')
            .where('status', isEqualTo: 'paid')
            .where('paidAt', isGreaterThanOrEqualTo: start)
            .where('paidAt', isLessThanOrEqualTo: end)
            .get();
      });

      final snaps = await Future.wait(futures);
      return List.generate(10, (i) {
        final day   = now.subtract(Duration(days: 9 - i));
        final total = snaps[i].docs.fold<double>(
            0, (s, d) => s + ((d.data()['amount'] as num?)?.toDouble() ?? 0));
        return ChartPoint(labels[day.weekday - 1], total);
      });
    } catch (_) {
      return [];
    }
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  Future<void> updateOrderStatus(
    String id,
    OrderStatus newStatus,
    String adminId,
    String adminName,
    Map<String, dynamic> before,
  ) async {
    try {
      final update = <String, dynamic>{
        'status': newStatus.firestoreValue,
        if (newStatus == OrderStatus.paid)
          'paidAt': FieldValue.serverTimestamp(),
      };

      final batch = _db.batch();
      batch.update(_db.collection('orders').doc(id), update);
      batch.set(_db.collection('audit_log').doc(), {
        'adminId': adminId,
        'adminName': adminName,
        'action': 'update_order_status',
        'targetId': id,
        'targetType': 'order',
        'before': before,
        'after': update,
        'performedAt': DateTime.now().toIso8601String(),
      });
      await batch.commit();
    } catch (e) {
      throw Exception('Statuswijziging mislukt: $e');
    }
  }

  Future<void> sendPaymentReminder(String userId, String auctionTitle) async {
    try {
      await _db.collection('notifications').add({
        'title': 'Vergeet niet te betalen',
        'body': 'Je gewonnen veiling "$auctionTitle" vervalt bijna. Betaal nu!',
        'target': 'specific',
        'targetUserId': userId,
        'status': 'scheduled',
        'scheduledFor': null,
        'sentBy': _auth.currentUser?.uid ?? '',
        'sentCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Herinnering verzenden mislukt: $e');
    }
  }

  // ── Mapper ───────────────────────────────────────────────────────────────────

  AdminOrderEntity _mapOrder(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AdminOrderEntity(
      id:                doc.id,
      auctionId:         d['auctionId']        ?? '',
      auctionTitle:      d['auctionTitle']      ?? '',
      userId:            d['userId']            ?? '',
      userName:          d['userName']          ?? 'Onbekend',
      userEmail:         d['userEmail']         ?? '',
      amount:            (d['amount'] as num?)?.toDouble() ?? 0,
      status:            OrderStatusX.fromString(d['status'] as String?),
      molliePaymentId:   d['molliePaymentId']   ?? '',
      mollieCheckoutUrl: d['mollieCheckoutUrl'] ?? '',
      paymentMethod:     d['paymentMethod']     as String?,
      createdAt:         _ts(d['createdAt']),
      paidAt:            _tsOpt(d['paidAt']),
      expiresAt:         _ts(d['expiresAt']),
    );
  }

  // Handles both Firestore Timestamp objects and ISO-8601 strings.
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
