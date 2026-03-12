import 'package:dio/dio.dart';

abstract class PaymentRemoteDatasource {
  Future<String> createPayment({required String orderId, required double amount, required String userId});
  Future<bool> verifyPayment(String paymentId);
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final Dio _dio;
  PaymentRemoteDatasourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<String> createPayment({required String orderId, required double amount, required String userId}) async {
    final response = await _dio.post(
      'https://your-backend.com/api/payments/create',
      data: {
        'orderId': orderId,
        'amount': amount,
        'userId': userId,
        'currency': 'EUR',
        'redirectUrl': 'auction://payment/result',
        'webhookUrl': 'https://your-backend.com/webhooks/mollie',
      },
    );
    return response.data['checkoutUrl'] as String;
  }

  @override
  Future<bool> verifyPayment(String paymentId) async {
    final response = await _dio.get('https://your-backend.com/api/payments/$paymentId/status');
    return response.data['status'] == 'paid';
  }
}
