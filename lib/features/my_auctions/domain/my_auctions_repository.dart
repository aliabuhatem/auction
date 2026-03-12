import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../auctions/domain/entities/auction_entity.dart';

abstract class MyAuctionsRepository {
  Future<Either<Failure, List<AuctionEntity>>> getActiveBids(String userId);
  Future<Either<Failure, List<AuctionEntity>>> getWonAuctions(String userId);
  Future<Either<Failure, List<AuctionEntity>>> getPendingPayments(String userId);
}
