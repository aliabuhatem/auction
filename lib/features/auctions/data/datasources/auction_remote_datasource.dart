import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';

abstract class AuctionRemoteDatasource {
  Future<List<AuctionModel>> getAuctions({String? category, String? query, int page = 1});
  Future<AuctionModel> getAuctionById(String id);
  Stream<AuctionModel> watchAuction(String id);
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName);
  Future<List<BidModel>> getBidHistory(String auctionId);
  Future<List<AuctionModel>> getAuctionsByIds(List<String> ids);
  Future<bool> setWatchlist(String auctionId, String userId, bool add);
  Future<bool> setAlarm(String auctionId, String userId, bool set);
}

class AuctionRemoteDatasourceImpl implements AuctionRemoteDatasource {
  final FirebaseFirestore firestore;
  AuctionRemoteDatasourceImpl({required this.firestore});

  CollectionReference get _auctions => firestore.collection('auctions');

  @override
  Future<List<AuctionModel>> getAuctions({String? category, String? query, int page = 1}) async {
    Query q = _auctions.where('status', isEqualTo: 'live').orderBy('endsAt').limit(20);
    if (category != null && category != 'all') {
      q = q.where('category', isEqualTo: category);
    }
    final snap = await q.get();
    var results = snap.docs.map((d) => AuctionModel.fromFirestore(d)).toList();
    if (query != null && query.isNotEmpty) {
      final q2 = query.toLowerCase();
      results = results.where((a) =>
        a.title.toLowerCase().contains(q2) ||
        a.location.toLowerCase().contains(q2) ||
        a.description.toLowerCase().contains(q2)
      ).toList();
    }
    return results;
  }

  @override
  Future<AuctionModel> getAuctionById(String id) async {
    final doc = await _auctions.doc(id).get();
    if (!doc.exists) throw Exception('Auction not found');
    return AuctionModel.fromFirestore(doc);
  }

  @override
  Stream<AuctionModel> watchAuction(String id) {
    return _auctions.doc(id).snapshots().map((doc) => AuctionModel.fromFirestore(doc));
  }

  @override
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName) async {
    return await firestore.runTransaction<bool>((tx) async {
      final ref = _auctions.doc(auctionId);
      final doc = await tx.get(ref);
      if (!doc.exists) throw Exception('Veiling niet gevonden');
      final data = doc.data() as Map<String, dynamic>;
      final currentBid = (data['currentBid'] as num).toDouble();
      final endsAt = (data['endsAt'] as Timestamp).toDate();
      if (amount <= currentBid) throw Exception('Bod moet hoger zijn dan het huidige bod');
      if (DateTime.now().isAfter(endsAt)) throw Exception('De veiling is afgelopen');
      tx.update(ref, {'currentBid': amount, 'bidCount': FieldValue.increment(1)});
      final bidRef = ref.collection('bids').doc();
      tx.set(bidRef, {
        'auctionId': auctionId,
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'placedAt': FieldValue.serverTimestamp(),
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
    final futures = ids.map((id) => _auctions.doc(id).get());
    final docs = await Future.wait(futures);
    return docs.where((d) => d.exists).map((d) => AuctionModel.fromFirestore(d)).toList();
  }

  @override
  Future<bool> setWatchlist(String auctionId, String userId, bool add) async {
    final userRef = firestore.collection('users').doc(userId);
    await userRef.update({
      'watchlist': add ? FieldValue.arrayUnion([auctionId]) : FieldValue.arrayRemove([auctionId])
    });
    return true;
  }

  @override
  Future<bool> setAlarm(String auctionId, String userId, bool set) async {
    final userRef = firestore.collection('users').doc(userId);
    await userRef.update({
      'alarms': set ? FieldValue.arrayUnion([auctionId]) : FieldValue.arrayRemove([auctionId])
    });
    return true;
  }
}
