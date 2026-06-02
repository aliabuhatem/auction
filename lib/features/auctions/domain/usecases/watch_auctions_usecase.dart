import '../entities/auction_entity.dart';
import '../repositories/auction_repository.dart';

class WatchAuctionsUseCase {
  final AuctionRepository repository;
  WatchAuctionsUseCase(this.repository);

  Stream<List<AuctionEntity>> call({AuctionCategory? category}) =>
      repository.watchAuctions(category: category);
}
