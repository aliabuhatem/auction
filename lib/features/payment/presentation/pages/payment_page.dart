import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';


class PaymentPage extends StatefulWidget {
  final String orderId;
  final double amount;
  final String auctionTitle;
  const PaymentPage({super.key, required this.orderId, required this.amount, required this.auctionTitle});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _paymentDone = false;

  @override
  void initState() {
    super.initState();
    // In production: fetch checkout URL from backend, then load it
    // For now show a placeholder
    _initWebView('https://your-backend.com/checkout/${widget.orderId}');
  }

  void _initWebView(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (req) {
          if (req.url.contains('payment/success') || req.url.contains('auction://payment')) {
            setState(() => _paymentDone = true);
            Navigator.of(context).pop(true);
            return NavigationDecision.prevent;
          }
          if (req.url.contains('payment/cancel')) {
            Navigator.of(context).pop(false);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(url));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Betalen', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundLight,
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Betaal ${CurrencyFormatter.format(widget.amount)} voor "${widget.auctionTitle}"',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_controller != null) WebViewWidget(controller: _controller!),
                if (_isLoading) const Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
