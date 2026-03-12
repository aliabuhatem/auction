// lib/features/tickets/presentation/pages/voucher_page.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/voucher_entity.dart';

class VoucherPage extends StatelessWidget {
  final String? voucherId;
  final VoucherEntity? voucher;
  
  const VoucherPage({super.key, this.voucherId, this.voucher});

  @override
  Widget build(BuildContext context) {
    if (voucher == null && voucherId == null) {
       return const Scaffold(body: Center(child: Text('Geen voucher gevonden')));
    }

    final displayVoucher = voucher ?? VoucherEntity(
      id: voucherId ?? '',
      code: '...',
      auctionId: '', // Added missing required parameter
      auctionTitle: 'Laden...',
      expiresAt: DateTime.now(),
      isUsed: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Mijn voucher'),
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
                    color: Colors.black.withOpacity(0.1),
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_activity, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayVoucher.auctionTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                              Text('Geldig t/m ${displayVoucher.expiresAtFormatted}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: QrImageView(
                      data: displayVoucher.code,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Text('Vouchercode',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          displayVoucher.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        if (displayVoucher.isUsed)
                          const Chip(
                            label: Text('Gebruikt'),
                            backgroundColor: Colors.grey,
                          ),
                      ],
                    ),
                  ),
                  _buildDashedDivider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Toon deze QR-code bij het inchecken aan de medewerker',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
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
        Expanded(
          child: CustomPaint(painter: DashedLinePainter()),
        ),
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
