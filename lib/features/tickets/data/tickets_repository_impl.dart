// lib/features/tickets/data/tickets_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../domain/tickets_repository.dart';
import '../domain/voucher_entity.dart';
import 'tickets_remote_datasource.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsRemoteDatasource datasource;
  const TicketsRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, List<VoucherEntity>>> getMyTickets(String userId) async {
    try {
      final result = await datasource.getMyTickets(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VoucherEntity>> getTicketById(String id) async {
    try {
      final result = await datasource.getTicketById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsUsed(String id) async {
    try {
      final result = await datasource.markAsUsed(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
