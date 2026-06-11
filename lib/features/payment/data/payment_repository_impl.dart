// lib/features/payment/data/payment_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../domain/payment_repository.dart';
import 'payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource datasource;
  const PaymentRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, String>> createPayment({
    required String orderId,
  }) async {
    try {
      final url = await datasource.createPayment(orderId: orderId);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
