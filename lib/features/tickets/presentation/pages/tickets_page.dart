import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/voucher_entity.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn vouchers', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example voucher card
          _VoucherCard(
            voucher: VoucherEntity(
              id: '1', code: 'VAKNL-2024-ABCD', auctionId: 'a1',
              auctionTitle: 'Wellness weekend Veluwe',
              expiresAt: DateTime.now().add(const Duration(days: 90)),
            ),
          ),
        ],
      ),
    );
  }
}

class VoucherDetailPage extends StatelessWidget {
  final VoucherEntity voucher;
  const VoucherDetailPage({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(AppStrings.myVoucher, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.download), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _VoucherCard(voucher: voucher, expanded: true),
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final VoucherEntity voucher;
  final bool expanded;
  const _VoucherCard({required this.voucher, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_activity, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(voucher.auctionTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Geldig t/m ${voucher.expiresAtFormatted}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                if (voucher.isUsed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Gebruikt', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
          ),
          // QR Code
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: QrImageView(
              data: voucher.code,
              version: QrVersions.auto,
              size: expanded ? 220 : 150,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.textPrimary),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.textPrimary),
            ),
          ),
          // Code
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: Column(children: [
              const Text(AppStrings.voucherCode, style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(voucher.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, style: BorderStyle.solid))),
              ),
              const SizedBox(height: 16),
              const Text(AppStrings.showQr, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
          ),
        ],
      ),
    );
  }
}
