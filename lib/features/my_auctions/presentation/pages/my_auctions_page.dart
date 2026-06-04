import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auctions/domain/entities/auction_entity.dart';
import '../bloc/my_auctions_bloc.dart';

class MyAuctionsPage extends StatefulWidget {
  const MyAuctionsPage({super.key});
  @override
  State<MyAuctionsPage> createState() => _MyAuctionsPageState();
}

class _MyAuctionsPageState extends State<MyAuctionsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  void _load() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<MyAuctionsBloc>().add(LoadMyAuctions(auth.user.id));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final userId = auth is AuthAuthenticated ? auth.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myAuctions(context),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: AppStrings.active(context)),
            Tab(text: AppStrings.won(context)),
            Tab(text: AppStrings.payNow(context)),
            Tab(text: AppStrings.saved(context)),
          ],
        ),
      ),
      body: BlocBuilder<MyAuctionsBloc, MyAuctionsState>(
        builder: (context, state) {
          if (state is MyAuctionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MyAuctionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: Text(AppStrings.retryBtn(context)),
                  ),
                ],
              ),
            );
          }

          final loaded = state is MyAuctionsLoaded ? state : null;

          return TabBarView(
            controller: _tabController,
            children: [
              _AuctionTab(
                auctions: loaded?.activeBids ?? [],
                emptyIcon: Icons.gavel,
                emptyMessage: AppStrings.noActive(context),
                onRefresh: _load,
              ),
              _AuctionTab(
                auctions: loaded?.wonAuctions ?? [],
                emptyIcon: Icons.emoji_events,
                emptyMessage: AppStrings.noWon(context),
                onRefresh: _load,
              ),
              _PendingPaymentTab(
                auctions: loaded?.pendingPayments ?? [],
                userId: userId,
                onRefresh: _load,
              ),
              _AuctionTab(
                auctions: loaded?.watchedAuctions ?? [],
                emptyIcon: Icons.bookmark_border,
                emptyMessage: AppStrings.noSaved(context),
                onRefresh: _load,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuctionTab extends StatelessWidget {
  final List<AuctionEntity> auctions;
  final IconData emptyIcon;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const _AuctionTab({
    required this.auctions,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: () async => onRefresh(),
        child: ListView(children: [
          SizedBox(
            height: 300,
            child: _EmptyTab(icon: emptyIcon, message: emptyMessage),
          ),
        ]),
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryRed,
      onRefresh: () async => onRefresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: auctions.length,
        itemBuilder: (context, i) => AuctionCard(auction: auctions[i]),
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
}

class _PendingPaymentTab extends StatelessWidget {
  final List<AuctionEntity> auctions;
  final String userId;
  final VoidCallback onRefresh;
  const _PendingPaymentTab({
    required this.auctions,
    required this.userId,
    required this.onRefresh,
  });

  Future<String?> _findOrderId(String auctionId) async {
    final snap = await FirebaseFirestore.instance
        .collection('orders')
        .where('auctionId', isEqualTo: auctionId)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.warningLight,
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.pendingPaymentWarning(context),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        if (auctions.isEmpty)
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () async => onRefresh(),
              child: ListView(children: [
                SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(AppStrings.noPending(context),
                        style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
              ]),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryRed,
              onRefresh: () async => onRefresh(),
              child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: auctions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = auctions[i];
                return Card(
                  child: ListTile(
                    leading:
                        const Icon(Icons.payment, color: AppColors.primaryRed),
                    title: Text(a.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(CurrencyFormatter.format(a.currentBid)),
                    trailing: _PayButton(
                      onPressed: () async {
                        final orderId = await _findOrderId(a.id);
                        if (!context.mounted) return;
                        if (orderId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppStrings.orderNotFoundMsg(context)),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                          return;
                        }
                        context.push(AppRoutes.paymentPath(orderId));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          ),
      ],
    );
  }
}

class _PayButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  const _PayButton({required this.onPressed});

  @override
  State<_PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<_PayButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              await widget.onPressed();
              if (mounted) setState(() => _loading = false);
            },
      child: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : Text(AppStrings.payNow(context), style: const TextStyle(color: Colors.white)),
    );
  }
}
