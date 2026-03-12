import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;
  AuthRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final user = await datasource.loginWithEmail(email, password);
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(_parseFirebaseError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String email, String password, String name) async {
    try {
      final user = await datasource.registerWithEmail(email, password, name);
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(_parseFirebaseError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final user = await datasource.loginWithGoogle();
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await datasource.logout();
      return const Right(true);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() => datasource.getCurrentUser();

  @override
  Stream<UserEntity?> get authStateChanges => datasource.authStateChanges;

  String _parseFirebaseError(String msg) {
    if (msg.contains('user-not-found')) return 'Geen account gevonden met dit e-mailadres';
    if (msg.contains('wrong-password')) return 'Onjuist wachtwoord';
    if (msg.contains('email-already-in-use')) return 'Er bestaat al een account met dit e-mailadres';
    if (msg.contains('invalid-email')) return 'Ongeldig e-mailadres';
    if (msg.contains('weak-password')) return 'Wachtwoord is te zwak (minimaal 6 tekens)';
    return 'Er is iets misgegaan. Probeer opnieuw.';
  }
}
