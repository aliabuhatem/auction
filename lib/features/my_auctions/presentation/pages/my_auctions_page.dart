import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';


class MyAuctionsPage extends StatefulWidget {
  const MyAuctionsPage({super.key});
  @override
  State<MyAuctionsPage> createState() => _MyAuctionsPageState();
}

class _MyAuctionsPageState extends State<MyAuctionsPage> with SingleTickerProviderStateMixin {
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
        title: const Text(AppStrings.myAuctions, style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryRed,
          labelColor: AppColors.primaryRed,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: AppStrings.active),
            Tab(text: AppStrings.won),
            Tab(text: AppStrings.payNow),
            Tab(text: AppStrings.saved),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _EmptyTab(icon: Icons.gavel, message: AppStrings.noActive),
          const _EmptyTab(icon: Icons.emoji_events, message: AppStrings.noWon),
          _PendingPaymentTab(),
          const _EmptyTab(icon: Icons.bookmark_border, message: AppStrings.noSaved),
        ],
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
        Icon(icon, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );
}

class _PendingPaymentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF3CD),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Expanded(
                child: Text(AppStrings.pendingPaymentWarning, style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const Expanded(child: Center(child: Text(AppStrings.noPending, style: TextStyle(color: Colors.grey)))),
      ],
    );
  }
}
