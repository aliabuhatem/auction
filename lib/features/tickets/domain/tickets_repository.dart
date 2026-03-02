import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import 'voucher_entity.dart';

abstract class TicketsRepository {
  Future<Either<Failure, List<VoucherEntity>>> getMyTickets(String userId);
  Future<Either<Failure, VoucherEntity>> getTicketById(String id);
  Future<Either<Failure, bool>> markAsUsed(String id);
}
