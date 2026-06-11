// lib/features/profile/presentation/pages/wallet_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/app_strings.dart';

/// A "received" transaction. Accepts both the canonical `credit` and the legacy
/// `earned` value some older docs may carry.
bool _isCredit(String type) => type == 'credit' || type == 'earned';

/// `createdAt` may be a Firestore [Timestamp] (canonical) or an ISO string
/// (legacy). Returns null if neither.
DateTime? _txDate(dynamic raw) {
  if (raw is Timestamp) return raw.toDate();
  if (raw is String) return DateTime.tryParse(raw);
  return null;
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<String> _filters(BuildContext context) => [
    AppStrings.all(context),
    AppStrings.filterReceived(context),
    AppStrings.filterUsed(context),
  ];
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        body: Center(child: Text(AppStrings.loginForWallet(context))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.wallet(context))),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, userSnap) {
          if (userSnap.hasError) {
            return Center(child: Text(AppStrings.walletLoadError(context)));
          }
          final userData = userSnap.hasData && userSnap.data!.exists
              ? (userSnap.data!.data() as Map<String, dynamic>? ?? {})
              : <String, dynamic>{};
          final balance = (userData['bidCredits'] as num?)?.toDouble() ?? 0.0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wallet_transactions')
                .where('userId', isEqualTo: uid)
                // No orderBy — avoids composite index requirement.
                // Sorted client-side below.
                .snapshots(),
            builder: (context, txSnap) {
              if (txSnap.hasError) {
                return Center(child: Text(AppStrings.txLoadError(context)));
              }
              // Sort descending by createdAt client-side.
              final allTx = List<QueryDocumentSnapshot>.from(
                  txSnap.data?.docs ?? [])
                ..sort((a, b) {
                  final ta = _txDate((a.data() as Map)['createdAt'])
                          ?.millisecondsSinceEpoch ?? 0;
                  final tb = _txDate((b.data() as Map)['createdAt'])
                          ?.millisecondsSinceEpoch ?? 0;
                  return tb.compareTo(ta);
                });
              final filtered = _filterIndex == 0
                  ? allTx
                  : allTx.where((d) {
                      final type = (d.data() as Map)['type'] as String? ?? '';
                      // 1 = received (credits), 2 = used (debits).
                      return _filterIndex == 1 ? _isCredit(type) : !_isCredit(type);
                    }).toList();

              final filters = _filters(context);
              return RefreshIndicator(
                onRefresh: () async =>
                    Future.delayed(const Duration(milliseconds: 600)),
                child: CustomScrollView(
                  slivers: [
                    // Balance header
                    SliverToBoxAdapter(
                      child: _BalanceCard(balance: balance),
                    ),

                    // Filter chips
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: filters.asMap().entries.map((e) {
                            final selected = e.key == _filterIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label:    Text(e.value),
                                selected: selected,
                                onSelected: (_) =>
                                    setState(() => _filterIndex = e.key),
                                selectedColor: AppColors.primaryRed,
                                labelStyle: TextStyle(
                                  color:      selected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize:   13,
                                ),
                                checkmarkColor: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          AppStrings.txHistory(context),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Transactions
                    if (txSnap.connectionState == ConnectionState.waiting)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (filtered.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined,
                                  size: 64, color: AppColors.textSecondary),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.noTransactions(context),
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _TxTile(data: filtered[i].data() as Map<String, dynamic>),
                          childCount: filtered.length,
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:     const EdgeInsets.all(16),
      padding:    const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder, width: 1),
        boxShadow: AppColors.goldGlow(opacity: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.biddingCredit(context).toUpperCase(),
            style: const TextStyle(
              color:    AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '€',
                style: TextStyle(
                  color:    AppColors.textSecondary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: balance),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => Text(
                  CurrencyFormatter.decimal(value),
                  style: const TextStyle(
                    color:      AppColors.textOnDark,
                    fontSize:   44,
                    fontWeight: FontWeight.w800,
                    height:     1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 14),
            const SizedBox(width: 6),
            Text(
              AppStrings.creditInfo(context),
              style: const TextStyle(
                color:    AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TxTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final type    = data['type'] as String? ?? 'debit';
    final isCredit = _isCredit(type);
    final amount  = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final desc    = data['description'] as String? ?? '';
    final dt      = _txDate(data['createdAt']);
    final locale  = Localizations.localeOf(context).toString();
    final date    = dt != null ? _formatDate(dt, locale) : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding:    const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:  (isCredit ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
          shape:  BoxShape.circle,
        ),
        child: Icon(
          isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
      title:    Text(desc, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(date, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        '${isCredit ? '+' : '-'} ${CurrencyFormatter.format(amount)}',
        style: TextStyle(
          color:      isCredit ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w800,
          fontSize:   15,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt, String locale) =>
      DateFormat.yMMMd(locale).format(dt);
}
