// lib/features/profile/data/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../domain/profile_repository.dart';
import 'profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource datasource;
  const ProfileRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile(String userId) async {
    try {
      final result = await datasource.getProfile(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(String userId, {
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      await datasource.updateProfile(userId,
          displayName: displayName, avatarUrl: avatarUrl);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
