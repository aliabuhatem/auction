import 'package:cloud_functions/cloud_functions.dart';

abstract class PaymentRemoteDatasource {
  /// Starts (or reuses) a Mollie checkout for [orderId] and returns the hosted
  /// checkout URL to open in the WebView / browser.
  Future<String> createPayment({required String orderId});
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final FirebaseFunctions _functions;
  PaymentRemoteDatasourceImpl({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<String> createPayment({required String orderId}) async {
    try {
      final callable = _functions.httpsCallable('createMolliePayment');
      final res = await callable.call<Map<String, dynamic>>({
        'orderId': orderId,
      });
      final url = res.data['checkoutUrl'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Geen checkout-URL ontvangen.');
      }
      return url;
    } on FirebaseFunctionsException catch (e) {
      // Surface the server's human-readable message to the UI.
      throw Exception(e.message ?? 'Betaling starten mislukt.');
    }
  }
}
