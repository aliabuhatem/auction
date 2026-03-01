// Auction repository abstract class

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auction_entity.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<AuctionEntity>>> getAuctions({
    AuctionCategory? category,
    String? searchQuery,
    int page = 1,
  });

  Future<Either<Failure, AuctionEntity>> getAuctionById(String id);

  Stream<AuctionEntity> watchAuction(String auctionId); // Real-time stream

  Future<Either<Failure, bool>> placeBid({
    required String auctionId,
    required double bidAmount,
  });

  Future<Either<Failure, List<AuctionEntity>>> getMyAuctions();
  Future<Either<Failure, List<AuctionEntity>>> getWonAuctions();
  Future<Either<Failure, bool>> setAuctionAlarm(String auctionId);
  Future<Either<Failure, bool>> removeAuctionAlarm(String auctionId);
  Future<Either<Failure, bool>> watchlistAuction(String auctionId);
}