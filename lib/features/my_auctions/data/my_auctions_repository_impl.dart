import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../auctions/domain/entities/auction_entity.dart';
import '../domain/my_auctions_repository.dart';
import 'my_auctions_remote_datasource.dart';

class MyAuctionsRepositoryImpl implements MyAuctionsRepository {
  final MyAuctionsRemoteDatasource remote;

  MyAuctionsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<AuctionEntity>>> getActiveBids(String userId) async {
    try {
      final result = await remote.getActiveBids(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuctionEntity>>> getWonAuctions(String userId) async {
    try {
      final result = await remote.getWonAuctions(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AuctionEntity>>> getPendingPayments(String userId) async {
    try {
      final result = await remote.getPendingPayments(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
