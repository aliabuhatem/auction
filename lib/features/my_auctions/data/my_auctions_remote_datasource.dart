import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auctions/data/models/auction_model.dart';

abstract class MyAuctionsRemoteDatasource {
  Future<List<AuctionModel>> getActiveBids(String userId);
  Future<List<AuctionModel>> getWonAuctions(String userId);
  Future<List<AuctionModel>> getPendingPayments(String userId);
}

class MyAuctionsRemoteDatasourceImpl implements MyAuctionsRemoteDatasource {
  final FirebaseFirestore firestore;
  MyAuctionsRemoteDatasourceImpl({required this.firestore});

  @override
  Future<List<AuctionModel>> getActiveBids(String userId) async {
    // Get all live auctions where the user has placed a bid
    final bidsQuery = await firestore.collectionGroup('bids')
        .where('userId', isEqualTo: userId)
        .orderBy('placedAt', descending: true)
        .get();

    final auctionIds = bidsQuery.docs.map((d) => d.data()['auctionId'] as String).toSet().toList();
    if (auctionIds.isEmpty) return [];

    final futures = auctionIds.take(10).map((id) => firestore.collection('auctions').doc(id).get());
    final docs = await Future.wait(futures);
    return docs.where((d) => d.exists && (d.data()!['status'] == 'live')).map((d) => AuctionModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<AuctionModel>> getWonAuctions(String userId) async {
    final snap = await firestore.collection('auctions').where('winnerId', isEqualTo: userId).get();
    return snap.docs.map((d) => AuctionModel.fromFirestore(d)).toList();
  }

  @override
  Future<List<AuctionModel>> getPendingPayments(String userId) async {
    final snap = await firestore.collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    final auctionIds = snap.docs.map((d) => d.data()['auctionId'] as String).toList();
    if (auctionIds.isEmpty) return [];
    final futures = auctionIds.map((id) => firestore.collection('auctions').doc(id).get());
    final docs = await Future.wait(futures);
    return docs.where((d) => d.exists).map((d) => AuctionModel.fromFirestore(d)).toList();
  }
}
