// WebSocket for live bidding

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  void connect(String auctionId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your-backend.com/ws/auction/$auctionId'),
    );
    _channel!.stream.listen(
          (data) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        _messageController.add(decoded);
      },
      onError: (error) => _messageController.addError(error),
      onDone: () => _reconnect(auctionId),
    );
  }

  void sendBid(double amount, String userId) {
    _channel?.sink.add(jsonEncode({
      'type': 'bid',
      'amount': amount,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  void _reconnect(String auctionId) {
    Future.delayed(const Duration(seconds: 3), () => connect(auctionId));
  }

  void disconnect() {
    _channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}