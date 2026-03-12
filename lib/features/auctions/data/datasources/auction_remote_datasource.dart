import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';
import '../../domain/entities/auction_entity.dart';

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

  // CollectionReference get _auctions => firestore.collection('auctions');

  final List<AuctionModel> _dummyAuctions = [
    AuctionModel(
      id: '1',
      title: 'Smart Watch Pro',
      description: 'Luxe smartwatch met alle functies die je nodig hebt.',
      imageUrl: 'assets/images/watch.png',
      imageUrls: const ['assets/images/watch.png'],
      currentBid: 45.0,
      startingBid: 1.0,
      bidCount: 12,
      endsAt: DateTime.now().add(const Duration(hours: 2)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Amsterdam, Nederland',
      retailValue: 150.0,
    ),
    AuctionModel(
      id: '2',
      title: 'High-End Monitor',
      description: 'Prachtig scherm voor werk en entertainment.',
      imageUrl: 'assets/images/screen.png',
      imageUrls:const ['assets/images/screen.png'],
      currentBid: 15.0,
      startingBid: 1.0,
      bidCount: 5,
      endsAt: DateTime.now().add(const Duration(minutes: 45)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Utrecht, Nederland',
      retailValue: 300.0,
    ),
    AuctionModel(
      id: '3',
      title: 'High-End Monitor',
      description: 'Prachtig scherm voor werk en entertainment.',
      imageUrl: 'assets/images/screen.png',
      imageUrls:const ['assets/images/screen.png'],
      currentBid: 15.0,
      startingBid: 1.0,
      bidCount: 5,
      endsAt: DateTime.now().add(const Duration(minutes: 45)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Utrecht, Nederland',
      retailValue: 300.0,
    ),
    AuctionModel(
      id: '4',
      title: 'High-End Monitor',
      description: 'Prachtig scherm voor werk en entertainment.',
      imageUrl: 'assets/images/screen.png',
      imageUrls:const ['assets/images/screen.png'],
      currentBid: 15.0,
      startingBid: 1.0,
      bidCount: 5,
      endsAt: DateTime.now().add(const Duration(minutes: 45)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Utrecht, Nederland',
      retailValue: 300.0,
    ),
    AuctionModel(
      id: '5',
      title: 'High-End Monitor',
      description: 'Prachtig scherm voor werk en entertainment.',
      imageUrl: 'assets/images/screen.png',
      imageUrls:const ['assets/images/screen.png'],
      currentBid: 15.0,
      startingBid: 1.0,
      bidCount: 5,
      endsAt: DateTime.now().add(const Duration(minutes: 45)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Utrecht, Nederland',
      retailValue: 300.0,
    ),
    AuctionModel(
      id: '6',
      title: 'High-End Monitor',
      description: 'Prachtig scherm voor werk en entertainment.',
      imageUrl: 'assets/images/screen.png',
      imageUrls: const ['assets/images/screen.png'],
      currentBid: 15.0,
      startingBid: 1.0,
      bidCount: 5,
      endsAt: DateTime.now().add(const Duration(minutes: 45)),
      status: AuctionStatus.live,
      category: AuctionCategory.products,
      location: 'Utrecht, Nederland',
      retailValue: 300.0,
    ),
  ];

  @override
  Future<List<AuctionModel>> getAuctions({String? category, String? query, int page = 1}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    var results = _dummyAuctions;
    if (category != null && category != 'all') {
      results = results.where((a) => a.category.name == category).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((a) => a.title.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  @override
  Future<AuctionModel> getAuctionById(String id) async {
    return _dummyAuctions.firstWhere((a) => a.id == id);
  }

  @override
  Stream<AuctionModel> watchAuction(String id) {
    return Stream.value(_dummyAuctions.firstWhere((a) => a.id == id));
  }

  @override
  Future<bool> placeBid(String auctionId, double amount, String userId, String? userName) async {
    return true;
  }

  @override
  Future<List<BidModel>> getBidHistory(String auctionId) async {
    return [];
  }

  @override
  Future<List<AuctionModel>> getAuctionsByIds(List<String> ids) async {
    return _dummyAuctions.where((a) => ids.contains(a.id)).toList();
  }

  @override
  Future<bool> setWatchlist(String auctionId, String userId, bool add) async {
    return true;
  }

  @override
  Future<bool> setAlarm(String auctionId, String userId, bool set) async {
    return true;
  }
}
