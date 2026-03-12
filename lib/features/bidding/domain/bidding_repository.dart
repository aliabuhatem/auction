import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../auctions/domain/entities/bid_entity.dart';

abstract class BiddingRepository {
  Future<Either<Failure, bool>> placeBid(String auctionId, double amount, String userId, String? userName);
  Stream<List<BidEntity>> streamBids(String auctionId);
}
