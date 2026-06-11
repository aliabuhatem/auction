import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';

abstract class PaymentRepository {
  /// Starts (or reuses) a Mollie checkout for [orderId] and returns the hosted
  /// checkout URL. Amount and ownership are validated server-side.
  Future<Either<Failure, String>> createPayment({required String orderId});
}
