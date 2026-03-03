import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';


class MyAuctionsPage extends StatefulWidget {
  const MyAuctionsPage({super.key});
  @override
  State<MyAuctionsPage> createState() => _MyAuctionsPageState();
}

class _MyAuctionsPageState extends State<MyAuctionsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: Text(AppStrings.myAuctions(context), style: const TextStyle(fontWeight: FontWeight.bold)),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _EmptyTab(icon: Icons.gavel, message: AppStrings.noActive(context)),
          _EmptyTab(icon: Icons.emoji_events, message: AppStrings.noWon(context)),
          const _PendingPaymentTab(),
          _EmptyTab(icon: Icons.bookmark_border, message: AppStrings.noSaved(context)),
        ],
      ),
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyTab({super.key, required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );
}

class _PendingPaymentTab extends StatelessWidget {
  const _PendingPaymentTab({super.key});
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
                child: Text(AppStrings.pendingPaymentWarning(context), style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(child: Center(child: Text(AppStrings.noPending(context), style: const TextStyle(color: Colors.grey)))),
      ],
    );
  }
}
