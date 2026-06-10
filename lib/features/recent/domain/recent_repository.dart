// lib/features/recent/domain/recent_repository.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../auctions/domain/entities/auction_entity.dart';

abstract class RecentRepository {
  /// Fire-and-forget: records that the current user viewed [auction].
  Future<void> recordView(AuctionEntity auction);

  /// Recently viewed auctions for the current user, newest first.
  Future<Either<Failure, List<AuctionEntity>>> getRecent();

  /// Clears the current user's view history.
  Future<Either<Failure, bool>> clear();
}
