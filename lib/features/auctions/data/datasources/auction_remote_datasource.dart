import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';

abstract class AuctionRemoteDatasource {
  Future<List<AuctionModel>> getAuctions({String? category, String? query, int page = 1});
  Stream<List<AuctionModel>> watchAuctions({String? category});
  Future<AuctionModel> getAuctionById(String id);
  Stream<AuctionModel> watchAuction(String id);
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName);
  Future<List<BidModel>> getBidHistory(String auctionId);
  Future<List<AuctionModel>> getAuctionsByIds(List<String> ids);
  Future<bool> setWatchlist(String auctionId, String userId, bool add);
  Future<bool> setAlarm(String auctionId, String userId, bool set);
}

/// NOTE: Requires Firestore composite indexes:
///   auctions: (status ASC, endsAt ASC)
///   auctions: (status ASC, category ASC, endsAt ASC)
class AuctionRemoteDatasourceImpl implements AuctionRemoteDatasource {
  final FirebaseFirestore firestore;

  // Cursor map for pagination — keyed by "category_query"
  final Map<String, DocumentSnapshot?> _cursors = {};
  static const int _pageSize = 20;

  AuctionRemoteDatasourceImpl({required this.firestore});

  CollectionReference get _auctions => firestore.collection('auctions');

  @override
  Future<List<AuctionModel>> getAuctions({
    String? category,
    String? query,
    int page = 1,
  }) async {
    final key = '${category ?? "all"}_${query ?? ""}';
    if (page == 1) _cursors.remove(key);

    Query q;
    if (category != null && category != 'all') {
      q = _auctions
          .where('status', whereIn: ['live', 'scheduled'])
          .where('category', isEqualTo: category)
          .orderBy('endsAt')
          .limit(_pageSize);
    } else {
      q = _auctions
          .where('status', whereIn: ['live', 'scheduled'])
          .orderBy('endsAt')
          .limit(_pageSize);
    }

    if (page > 1 && _cursors[key] != null) {
      q = q.startAfterDocument(_cursors[key]!);
    }

    final snap = await q.get();
    if (snap.docs.isNotEmpty) _cursors[key] = snap.docs.last;

    var results = snap.docs.map((d) => AuctionModel.fromFirestore(d)).toList();

    // Client-side text filter (Firestore doesn't support full-text search)
    if (query != null && query.isNotEmpty) {
      final lq = query.toLowerCase();
      results = results
          .where((a) =>
              a.title.toLowerCase().contains(lq) ||
              a.description.toLowerCase().contains(lq))
          .toList();
    }

    return results;
  }

  @override
  Stream<List<AuctionModel>> watchAuctions({String? category}) {
    Query q;
    if (category != null && category != 'all') {
      q = _auctions
          .where('status', whereIn: ['live', 'scheduled'])
          .where('category', isEqualTo: category)
          .orderBy('endsAt')
          .limit(_pageSize);
    } else {
      q = _auctions
          .where('status', whereIn: ['live', 'scheduled'])
          .orderBy('endsAt')
          .limit(_pageSize);
    }
    return q.snapshots().map(
      (snap) => snap.docs.map((d) => AuctionModel.fromFirestore(d)).toList(),
    );
  }

  @override
  Future<AuctionModel> getAuctionById(String id) async {
    final doc = await _auctions.doc(id).get();
    if (!doc.exists) throw Exception('Auction not found');
    return AuctionModel.fromFirestore(doc);
  }

  @override
  Stream<AuctionModel> watchAuction(String id) => _auctions
      .doc(id)
      .snapshots()
      .where((doc) => doc.exists)
      .map((doc) => AuctionModel.fromFirestore(doc));

  @override
  Future<bool> placeBid(
      String auctionId, double amount, String userId, String? userName) {
    return firestore.runTransaction<bool>((tx) async {
      final ref = _auctions.doc(auctionId);
      final doc = await tx.get(ref);
      if (!doc.exists) throw Exception('Auction not found');

      final d   = doc.data()! as Map<String, dynamic>;
      final cur = (d['currentBid'] as num).toDouble();
      // endsAt may be a Timestamp (created) or an ISO String (older edits).
      final rawEnd = d['endsAt'];
      final end = rawEnd is Timestamp
          ? rawEnd.toDate()
          : (rawEnd is String
              ? (DateTime.tryParse(rawEnd) ?? DateTime.now())
              : DateTime.now());
      final inc = (d['minBidIncrement'] as num?)?.toDouble() ?? 1.0;
      final extSec = (d['extensionSeconds'] as int?) ?? 30;

      if (amount < cur + inc) {
        throw Exception(
            'Minimum bid is ${CurrencyFormatter.format(cur + inc)}');
      }
      if (DateTime.now().isAfter(end)) {
        throw Exception('This auction has already ended');
      }

      // Auto-extend: if bid placed in last 60 seconds, add extensionSeconds
      final timeLeft = end.difference(DateTime.now());
      final updates = <String, dynamic>{
        'currentBid':   amount,
        'bidCount':     FieldValue.increment(1),
        'lastBidderId': userId,
      };
      if (timeLeft.inSeconds <= 60) {
        updates['endsAt'] = Timestamp.fromDate(end.add(Duration(seconds: extSec)));
      }

      tx.update(ref, updates);

      tx.set(ref.collection('bids').doc(), {
        'auctionId': auctionId,
        'userId':    userId,
        'userName':  userName ?? 'Anonymous',
        'amount':    amount,
        'placedAt':  FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  @override
  Future<List<BidModel>> getBidHistory(String auctionId) async {
    final snap = await _auctions
        .doc(auctionId)
        .collection('bids')
        .orderBy('placedAt', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => BidModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<AuctionModel>> getAuctionsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Firestore whereIn supports max 30 items per query
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 30) {
      chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
    }
    final results = <AuctionModel>[];
    for (final chunk in chunks) {
      final snap = await _auctions.where(FieldPath.documentId, whereIn: chunk).get();
      results.addAll(snap.docs.map((d) => AuctionModel.fromFirestore(d)));
    }
    return results;
  }

  @override
  Future<bool> setWatchlist(String auctionId, String userId, bool add) async {
    final userRef = firestore.collection('users').doc(userId);
    if (add) {
      await userRef.update({
        'watchlist': FieldValue.arrayUnion([auctionId]),
      });
    } else {
      await userRef.update({
        'watchlist': FieldValue.arrayRemove([auctionId]),
      });
    }
    return true;
  }

  @override
  Future<bool> setAlarm(String auctionId, String userId, bool set) async {
    final userRef = firestore.collection('users').doc(userId);
    if (set) {
      await userRef.update({
        'alarms': FieldValue.arrayUnion([auctionId]),
      });
    } else {
      await userRef.update({
        'alarms': FieldValue.arrayRemove([auctionId]),
      });
    }
    return true;
  }
}
