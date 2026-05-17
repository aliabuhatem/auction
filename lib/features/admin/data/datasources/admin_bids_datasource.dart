import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_bid_entity.dart';

class AdminBidsDatasource {
  final FirebaseFirestore _db;

  AdminBidsDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<AdminBidEntity>> getBids({
    String? auctionId,
    String? userId,
    String? search,
    int     limit = 200,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _db
          .collectionGroup('bids')
          .orderBy('createdAt', descending: true);

      if (auctionId != null) q = q.where('auctionId', isEqualTo: auctionId);
      if (userId    != null) q = q.where('userId',    isEqualTo: userId);

      final snap = await q.limit(limit).get();
      var   bids = snap.docs.map(_mapBid).toList();

      if (search != null && search.isNotEmpty) {
        final s = search.toLowerCase();
        bids = bids
            .where((b) =>
                b.userName.toLowerCase().contains(s) ||
                b.auctionTitle.toLowerCase().contains(s))
            .toList();
      }

      return bids;
    } catch (e) {
      throw Exception('Fout bij ophalen biedingen: $e');
    }
  }

  Future<BidStatsEntity> getBidStats() async {
    try {
      final now        = DateTime.now();
      final todayStart = Timestamp.fromDate(DateTime(now.year, now.month, now.day));

      final results = await Future.wait([
        _db.collectionGroup('bids').count().get(),
        _db.collectionGroup('bids')
            .where('createdAt', isGreaterThanOrEqualTo: todayStart)
            .count()
            .get(),
        _db.collectionGroup('bids')
            .orderBy('amount', descending: true)
            .limit(1)
            .get(),
        _db.collection('auctions')
            .where('status', isEqualTo: 'live')
            .count()
            .get(),
      ]);

      final topSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;
      final highest = topSnap.docs.isNotEmpty
          ? (topSnap.docs.first.data()['amount'] as num?)?.toDouble() ?? 0
          : 0.0;

      return BidStatsEntity(
        totalBids:      (results[0] as AggregateQuerySnapshot).count ?? 0,
        todayBids:      (results[1] as AggregateQuerySnapshot).count ?? 0,
        highestBid:     highest,
        activeAuctions: (results[3] as AggregateQuerySnapshot).count ?? 0,
      );
    } catch (_) {
      return const BidStatsEntity(
          totalBids: 0, todayBids: 0, highestBid: 0, activeAuctions: 0);
    }
  }

  AdminBidEntity _mapBid(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AdminBidEntity(
      id:           doc.id,
      userId:       d['userId']       as String? ?? '',
      userName:     d['userName']     as String? ?? 'Onbekend',
      auctionId:    d['auctionId']    as String? ?? '',
      auctionTitle: d['auctionTitle'] as String? ?? '',
      amount:       (d['amount']      as num?)?.toDouble() ?? 0,
      createdAt:    _ts(d['createdAt']),
    );
  }

  static DateTime _ts(dynamic v, [DateTime? fallback]) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
    return fallback ?? DateTime.now();
  }
}
