import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);
  @override
  Future<Either<Failure, bool>> call(NoParams p) => repository.logout();
}
