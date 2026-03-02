import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

class WatchAuctionUseCase {
  final AuctionRepository repository;
  WatchAuctionUseCase(this.repository);
  Stream<AuctionEntity> call(String auctionId) => repository.watchAuction(auctionId);
}
