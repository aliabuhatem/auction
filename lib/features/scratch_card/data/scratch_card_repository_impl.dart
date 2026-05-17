// lib/features/scratch_card/data/scratch_card_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../domain/scratch_card_repository.dart';
import 'scratch_card_remote_datasource.dart';

class ScratchCardRepositoryImpl implements ScratchCardRepository {
  final ScratchCardRemoteDatasource datasource;
  const ScratchCardRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getScratchCardData(String userId) async {
    try {
      final result = await datasource.getScratchCardData(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> revealPrize(String userId) async {
    try {
      final result = await datasource.revealPrize(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> recordScratch(String userId, String prize) async {
    try {
      await datasource.recordScratch(userId, prize);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
