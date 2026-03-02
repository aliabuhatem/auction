import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams p) => repository.register(p.email, p.password, p.name);
}
class RegisterParams {
  final String email, password, name;
  const RegisterParams({required this.email, required this.password, required this.name});
}
