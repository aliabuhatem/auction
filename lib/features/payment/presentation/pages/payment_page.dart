// lib/features/payment/presentation/pages/payment_page.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  const PaymentPage({super.key, required this.orderId});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? _order;
  bool  _loading    = true;
  bool  _paying     = false;
  String? _error;

  StreamSubscription? _orderSub;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  void _loadOrder() {
    _orderSub = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) {
        setState(() { _loading = false; _error = 'Bestelling niet gevonden.'; });
        return;
      }
      final data = snap.data()!;
      setState(() { _order = data; _loading = false; });

      // Auto-navigate when Firestore marks order as paid (webhook/backend update).
      if (data['status'] == 'paid') {
        _orderSub?.cancel();
        if (mounted) _onPaymentSuccess(data);
      }
    }, onError: (e) {
      final msg = e.toString().contains('PERMISSION_DENIED')
          ? 'Je hebt geen toegang tot deze bestelling.'
          : 'Fout bij laden bestelling. Probeer het opnieuw.';
      setState(() { _loading = false; _error = msg; });
    });
  }

  void _onPaymentSuccess(Map<String, dynamic> order) {
    context.go(
      AppRoutes.paymentSuccess,
      extra: {
        'orderId':      widget.orderId,
        'voucherId':    order['voucherId'] as String?,
        'auctionTitle': order['auctionTitle'] as String? ?? '',
        'amount':       (order['amount'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  Future<void> _startPayment() async {
    if (_order == null) return;
    setState(() => _paying = true);

    try {
      final checkoutUrl = _order!['checkoutUrl'] as String?;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        // In a real implementation the backend/Cloud Function creates the
        // Mollie payment and writes checkoutUrl to the order document.
        // Show a user-friendly error until backend is wired.
        _showError('Betaallink nog niet beschikbaar. Probeer het opnieuw.');
        setState(() => _paying = false);
        return;
      }

      if (kIsWeb) {
        // Web: redirect in the same tab.
        await launchUrl(Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication);
      } else {
        // Mobile: in-app WebView.
        if (mounted) {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => _MollieWebView(
              url:     checkoutUrl,
              orderId: widget.orderId,
              onSuccess: () {
                Navigator.of(context).pop();
                _orderSub?.cancel();
                _onPaymentSuccess(_order!);
              },
              onFailure: (msg) {
                Navigator.of(context).pop();
                _showError(msg);
              },
            ),
          ));
        }
      }
    } catch (e) {
      _showError('Betaling mislukt: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:          Text(msg),
        backgroundColor:  AppColors.error,
        behavior:         SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:   const Text('Betaling'),
        leading: BackButton(onPressed: () => context.go(AppRoutes.myAuctions)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBody(message: _error!, onRetry: _loadOrder)
              : _OrderSummary(
                  order:   _order!,
                  paying:  _paying,
                  onPay:   _startPayment,
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool                 paying;
  final VoidCallback         onPay;
  const _OrderSummary({required this.order, required this.paying, required this.onPay});

  @override
  Widget build(BuildContext context) {
    final amount    = (order['amount'] as num?)?.toDouble() ?? 0.0;
    final title     = order['auctionTitle'] as String? ?? 'Veiling';
    final deadline  = order['paymentDeadline'] != null
        ? (order['paymentDeadline'] as Timestamp).toDate()
        : null;
    final isExpired = deadline != null && deadline.isBefore(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding:    const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color:        AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              border:       Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.emoji_events, color: AppColors.accentGold, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gefeliciteerd! Je hebt gewonnen.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _Row(label: 'Veiling',   value: title),
                const SizedBox(height: 8),
                _Row(label: 'Bestelnr.', value: '#${order['id'] ?? ''}'),
                const SizedBox(height: 8),
                _Row(
                  label: 'Bedrag',
                  value: '€ ${amount.toStringAsFixed(2)}',
                  valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color:      AppColors.primaryRed,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 8),
                  _Row(
                    label: 'Betalen vóór',
                    value: _formatDeadline(deadline),
                    valueStyle: TextStyle(
                      color:      isExpired ? AppColors.error : AppColors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (isExpired) ...[
            const SizedBox(height: 16),
            Container(
              padding:    const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(children: [
                Icon(Icons.warning_rounded, color: AppColors.error),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'De betaaltermijn is verlopen. Neem contact op met support.',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ]),
            ),
          ],

          const SizedBox(height: 32),

          // Payment info
          const Text(
            'Veilige betaling via Mollie',
            style: TextStyle(
              fontSize:   13,
              color:      AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PayBadge(label: 'iDEAL'),
              _PayBadge(label: 'Creditcard'),
              _PayBadge(label: 'PayPal'),
              _PayBadge(label: 'Bancontact'),
            ],
          ),
          const SizedBox(height: 40),

          // Pay button
          SizedBox(
            width:  double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isExpired ? null : (paying ? null : onPay),
              icon: paying
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.payment_rounded),
              label: Text(paying ? 'Bezig...' : 'Betaal nu € ${amount.toStringAsFixed(2)}'),
            ),
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text(
              '🔒 Beveiligd door SSL',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadline(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Verlopen';
    if (diff.inHours < 1) return '${diff.inMinutes} minuten';
    if (diff.inHours < 24) return '${diff.inHours} uur';
    return '${diff.inDays} dag${diff.inDays == 1 ? '' : 'en'}';
  }
}

class _Row extends StatelessWidget {
  final String      label;
  final String      value;
  final TextStyle?  valueStyle;
  const _Row({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PayBadge extends StatelessWidget {
  final String label;
  const _PayBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border:       Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String        message;
  final VoidCallback  onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Opnieuw proberen')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// In-app WebView for Mollie checkout (mobile only)
// ─────────────────────────────────────────────────────────────────────────────

class _MollieWebView extends StatefulWidget {
  final String    url;
  final String    orderId;
  final VoidCallback   onSuccess;
  final void Function(String) onFailure;
  const _MollieWebView({
    required this.url,
    required this.orderId,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<_MollieWebView> createState() => _MollieWebViewState();
}

class _MollieWebViewState extends State<_MollieWebView> {
  late final WebViewController _wvc;
  bool _loadingWeb = true;

  @override
  void initState() {
    super.initState();
    _wvc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted:  (_) => setState(() => _loadingWeb = true),
        onPageFinished: (_) => setState(() => _loadingWeb = false),
        onNavigationRequest: (req) {
          final url = req.url;
          if (url.contains('payment/success') || url.contains('status=paid')) {
            widget.onSuccess();
            return NavigationDecision.prevent;
          }
          if (url.contains('payment/cancel') || url.contains('status=cancel')) {
            widget.onFailure('Betaling geannuleerd.');
            return NavigationDecision.prevent;
          }
          if (url.contains('payment/fail') || url.contains('status=failed')) {
            widget.onFailure('Betaling mislukt. Probeer het opnieuw.');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veilig betalen'),
        leading: IconButton(
          icon:      const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title:   const Text('Betaling annuleren?'),
                content: const Text('Wil je de betaling annuleren?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Terug'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onFailure('Betaling geannuleerd.');
                    },
                    child: const Text('Annuleren',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _wvc),
          if (_loadingWeb)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color:           AppColors.primaryRed,
            ),
        ],
      ),
    );
  }
}
