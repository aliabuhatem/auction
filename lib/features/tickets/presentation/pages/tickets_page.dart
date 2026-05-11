import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/tickets_remote_datasource.dart';
import '../../domain/voucher_entity.dart';

class TicketsPage extends StatelessWidget {
  const TicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Log in om je vouchers te zien')),
      );
    }
    final userId = auth.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn vouchers', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<VoucherEntity>>(
        future: TicketsRemoteDatasourceImpl().getMyTickets(userId),
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
                  Text('Fout: ${snap.error}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final vouchers = snap.data ?? [];
          if (vouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_activity_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(AppStrings.noTickets(context),
                      style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Win een veiling om een voucher te ontvangen',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => _VoucherCard(
              voucher: vouchers[i],
              onTap: () => context.push(AppRoutes.voucherDetailPath(vouchers[i].id)),
            ),
          );
        },
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
        title: Text(AppStrings.myVoucher(context), style: const TextStyle(fontWeight: FontWeight.bold)),
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
  final VoidCallback? onTap;
  const _VoucherCard({required this.voucher, this.expanded = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          children: [
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
                      Text(voucher.auctionTitle,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Geldig t/m ${voucher.expiresAtFormatted}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: QrImageView(
                data: voucher.code,
                version: QrVersions.auto,
                size: expanded ? 220 : 150,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.textPrimary),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square, color: AppColors.textPrimary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: Column(children: [
                Text(AppStrings.voucherCode(context), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(voucher.code,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(AppStrings.showQr(context),
                    textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
