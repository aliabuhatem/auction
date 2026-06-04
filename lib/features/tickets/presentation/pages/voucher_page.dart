// lib/features/tickets/presentation/pages/voucher_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../data/tickets_remote_datasource.dart';
import '../../domain/voucher_entity.dart';

class VoucherPage extends StatelessWidget {
  final String? voucherId;
  final VoucherEntity? voucher;

  const VoucherPage({super.key, this.voucherId, this.voucher});

  @override
  Widget build(BuildContext context) {
    if (voucher != null) return _VoucherDetail(voucher: voucher!);

    if (voucherId == null) {
      return Builder(builder: (ctx) => Scaffold(
          body: Center(child: Text(AppStrings.voucherNotFound(ctx)))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(title: Builder(builder: (ctx) =>
          Text(AppStrings.myVoucher(ctx)))),
      body: FutureBuilder<VoucherEntity>(
        future: TicketsRemoteDatasourceImpl().getTicketById(voucherId!),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('${AppStrings.errorPrefix(context)}${snap.error}',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return _VoucherDetail(voucher: snap.data!);
        },
      ),
    );
  }
}

class _VoucherDetail extends StatelessWidget {
  final VoucherEntity voucher;
  const _VoucherDetail({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(AppStrings.myVoucher(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE63946),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_activity,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voucher.auctionTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${AppStrings.validUntil(context)} ${voucher.expiresAtFormatted}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (voucher.isUsed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(AppStrings.usedStatus(context),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                        if (voucher.isExpired && !voucher.isUsed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(AppStrings.expiredStatus(context),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11)),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: QrImageView(
                      data: voucher.code,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Text(AppStrings.voucherCode(context),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          voucher.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDashedDivider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      AppStrings.showQrAtCheckin(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(child: CustomPaint(painter: DashedLinePainter())),
        const SizedBox(
          width: 24,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF0F4F8),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
