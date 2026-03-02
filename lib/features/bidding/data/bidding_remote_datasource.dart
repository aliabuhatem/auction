import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auctions/data/models/bid_model.dart';

abstract class BiddingRemoteDatasource {
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName);
  Stream<List<BidModel>> streamBids(String auctionId);
}

class BiddingRemoteDatasourceImpl implements BiddingRemoteDatasource {
  final FirebaseFirestore firestore;
  BiddingRemoteDatasourceImpl({required this.firestore});

  @override
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName) async {
    return firestore.runTransaction<bool>((tx) async {
      final ref = firestore.collection('auctions').doc(auctionId);
      final doc = await tx.get(ref);
      if (!doc.exists) throw Exception('Veiling niet gevonden');
      final d = doc.data()!;
      final cur = (d['currentBid'] as num).toDouble();
      final end = (d['endsAt'] as Timestamp).toDate();
      if (amount <= cur) throw Exception('Bod moet hoger zijn dan het huidige bod (${cur.toStringAsFixed(2)})');
      if (DateTime.now().isAfter(end)) throw Exception('De veiling is al afgelopen');
      tx.update(ref, {'currentBid': amount, 'bidCount': FieldValue.increment(1)});
      tx.set(ref.collection('bids').doc(), {
        'auctionId': auctionId, 'userId': userId, 'userName': userName,
        'amount': amount, 'placedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
  }

  @override
  Stream<List<BidModel>> streamBids(String auctionId) => firestore
      .collection('auctions').doc(auctionId).collection('bids')
      .orderBy('placedAt', descending: true).limit(20)
      .snapshots()
      .map((s) => s.docs.map((d) => BidModel.fromFirestore(d)).toList());
}
