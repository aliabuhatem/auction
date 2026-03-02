import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

abstract class ScratchCardRepository {
  Future<Either<Failure, Map<String, dynamic>>> getScratchCardData(String userId);
  Future<Either<Failure, String>> revealPrize(String userId);
  Future<Either<Failure, bool>> recordScratch(String userId, String prize);
}
