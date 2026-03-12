import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/auction_remote_datasource.dart';
import '../datasources/auction_local_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDatasource remote;
  final AuctionLocalDatasource  local;

  AuctionRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<AuctionEntity>>> getAuctions({
    AuctionCategory? category,
    String?          searchQuery,
    int              page = 1,
  }) async {
    try {
      final results = await remote.getAuctions(
        category: category?.name,
        query:    searchQuery,
        page:     page,
      );
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuctionEntity>> getAuctionById(String id) async {
    try {
      return Right(await remote.getAuctionById(id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<AuctionEntity> watchAuction(String auctionId) =>
      remote.watchAuction(auctionId);

  @override
  Future<Either<Failure, bool>> placeBid({
    required String auctionId,
    required double bidAmount,
    String?         userId,
    String?         userName,
  }) async {
    try {
      final result =
          await remote.placeBid(auctionId, bidAmount, userId ?? '', userName);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuctionEntity>>> getMyAuctions() async {
    try {
      final ids     = await local.getWatchlist();
      final results = await remote.getAuctionsByIds(ids);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuctionEntity>>> getWonAuctions() async =>
      const Right([]);

  // FIX: implement setAuctionAlarm
  @override
  Future<Either<Failure, bool>> setAuctionAlarm(String auctionId) async {
    try {
      final alarms = await local.getAlarms();
      if (!alarms.contains(auctionId)) {
        alarms.add(auctionId);
        await local.saveAlarms(alarms);
      }
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // FIX: implement removeAuctionAlarm (was missing → caused the compile error)
  @override
  Future<Either<Failure, bool>> removeAuctionAlarm(String auctionId) async {
    try {
      final alarms = await local.getAlarms();
      alarms.remove(auctionId);
      await local.saveAlarms(alarms);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> watchlistAuction(String auctionId) async {
    try {
      final watchlist = await local.getWatchlist();
      if (watchlist.contains(auctionId)) {
        watchlist.remove(auctionId);
      } else {
        watchlist.add(auctionId);
      }
      await local.saveWatchlist(watchlist);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
