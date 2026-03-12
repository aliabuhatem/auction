import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  @override
  Future<Either<Failure, UserEntity>> call(LoginParams p) => repository.login(p.email, p.password);
}
class LoginParams {
  final String email, password;
  const LoginParams({required this.email, required this.password});
}
