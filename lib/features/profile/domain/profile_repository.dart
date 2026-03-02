import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile(String userId);
  Future<Either<Failure, bool>> updateProfile(String userId, {String? displayName, String? avatarUrl});
}
