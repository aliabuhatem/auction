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
  Future<Either<Failure, UserEntity>> register(String email, String password, String name,
      {String? referralCode}) async {
    try {
      final user = await datasource.registerWithEmail(email, password, name,
          referralCode: referralCode);
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
    if (msg.contains('user-not-found'))      return 'No account found with this email address';
    if (msg.contains('wrong-password'))      return 'Incorrect password. Please try again';
    if (msg.contains('email-already-in-use')) return 'An account with this email already exists';
    if (msg.contains('invalid-email'))       return 'Invalid email address';
    if (msg.contains('weak-password'))       return 'Password is too weak (minimum 6 characters)';
    if (msg.contains('too-many-requests'))   return 'Too many attempts. Please try again later';
    if (msg.contains('network-request-failed')) return 'Network error. Check your internet connection';
    if (msg.contains('invalid-credential'))  return 'Invalid credentials';
    return 'Something went wrong. Please try again';
  }
}
