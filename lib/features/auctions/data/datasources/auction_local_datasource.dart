import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auction_model.dart';

abstract class AuctionLocalDatasource {
  Future<void> cacheAuctions(List<AuctionModel> auctions);
  Future<List<AuctionModel>> getCachedAuctions();
  Future<void> cacheAuction(AuctionModel auction);
  Future<AuctionModel?> getCachedAuction(String id);
  Future<void> clearCache();
  Future<List<String>> getWatchlist();
  Future<void> saveWatchlist(List<String> ids);
  Future<List<String>> getAlarms();
  Future<void> saveAlarms(List<String> ids);
}

class AuctionLocalDatasourceImpl implements AuctionLocalDatasource {
  final SharedPreferences prefs;
  static const _auctionsKey   = 'cached_auctions';
  static const _watchlistKey  = 'watchlist_ids';
  static const _alarmsKey     = 'alarm_ids';
  static const _auctionPrefix = 'auction_';

  AuctionLocalDatasourceImpl({required this.prefs});

  @override
  Future<void> cacheAuctions(List<AuctionModel> auctions) async {
    final data = auctions.map((a) => a.toJson()).toList();
    await prefs.setString(_auctionsKey, jsonEncode(data));
  }

  @override
  Future<List<AuctionModel>> getCachedAuctions() async {
    final raw = prefs.getString(_auctionsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    // Note: fromJson would need Timestamp handling — simplified here
    return [];
  }

  @override
  Future<void> cacheAuction(AuctionModel auction) async {
    await prefs.setString('$_auctionPrefix${auction.id}', jsonEncode(auction.toJson()));
  }

  @override
  Future<AuctionModel?> getCachedAuction(String id) async {
    final raw = prefs.getString('$_auctionPrefix$id');
    if (raw == null) return null;
    return null; // Deserialize as needed
  }

  @override
  Future<void> clearCache() async {
    final keys = prefs.getKeys().where((k) => k.startsWith(_auctionPrefix) || k == _auctionsKey);
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  @override
  Future<List<String>> getWatchlist() async =>
      prefs.getStringList(_watchlistKey) ?? [];

  @override
  Future<void> saveWatchlist(List<String> ids) async =>
      prefs.setStringList(_watchlistKey, ids);

  @override
  Future<List<String>> getAlarms() async =>
      prefs.getStringList(_alarmsKey) ?? [];

  @override
  Future<void> saveAlarms(List<String> ids) async =>
      prefs.setStringList(_alarmsKey, ids);
}
