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
    required double amount,
    required String userId,
  }) async {
    try {
      final url = await datasource.createPayment(
        orderId: orderId,
        amount:  amount,
        userId:  userId,
      );
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment(String paymentId) async {
    try {
      final result = await datasource.verifyPayment(paymentId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
