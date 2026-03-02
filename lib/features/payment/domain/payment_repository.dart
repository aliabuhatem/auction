import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

abstract class PaymentRepository {
  Future<Either<Failure, String>> createPayment({required String orderId, required double amount, required String userId});
  Future<Either<Failure, bool>> verifyPayment(String paymentId);
}
