import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myAuctions(context),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Opnieuw proberen'),
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
              ),
              _AuctionTab(
                auctions: loaded?.wonAuctions ?? [],
                emptyIcon: Icons.emoji_events,
                emptyMessage: AppStrings.noWon(context),
              ),
              _PendingPaymentTab(auctions: loaded?.pendingPayments ?? []),
              _EmptyTab(
                icon: Icons.bookmark_border,
                message: AppStrings.noSaved(context),
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

  const _AuctionTab({
    required this.auctions,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) {
      return _EmptyTab(icon: emptyIcon, message: emptyMessage);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: auctions.length,
      itemBuilder: (context, i) => AuctionCard(auction: auctions[i]),
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
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
}

class _PendingPaymentTab extends StatelessWidget {
  final List<AuctionEntity> auctions;
  const _PendingPaymentTab({required this.auctions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF3CD),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFFF9800)),
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
            child: Center(
              child: Text(AppStrings.noPending(context),
                  style: const TextStyle(color: Colors.grey)),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: auctions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final a = auctions[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: AppColors.primaryRed),
                    title: Text(a.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('€${a.currentBid.toStringAsFixed(2)}'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed),
                      onPressed: () => context.push('/auction/${a.id}'),
                      child: const Text('Betalen',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
