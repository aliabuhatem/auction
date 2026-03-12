import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_dashboard_bloc.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_chart.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../../../core/constants/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        context.read<AdminRemoteDatasource>())..add(LoadDashboardStats()),
      child: AdminShell(
        selectedIndex: 0,
        child: const _DashboardBody(),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading || state is AdminDashboardInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
        }
        if (state is AdminDashboardError) {
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.message, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AdminDashboardBloc>().add(LoadDashboardStats()),
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ));
        }
        if (state is AdminDashboardLoaded) {
          return _DashboardContent(stats: state.stats);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardStatsEntity stats;
  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    final euro = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──────────────────────────────────────────────────────────
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard', style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF1A1D27))),
                  SizedBox(height: 2),
                  Text('Live overzicht van alle veilingen & activiteit',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
                ],
              ),
              const Spacer(),
              _RefreshButton(),
            ],
          ),
          const SizedBox(height: 24),

          // ── Stat cards ──────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: AdminStatCard(
              label:    'Live veilingen',
              value:    '${stats.liveAuctions}',
              icon:     Icons.gavel_rounded,
              color:    AppColors.primaryRed,
              subtitle: '${stats.totalAuctions} totaal',
            )),
            const SizedBox(width: 16),
            Expanded(child: AdminStatCard(
              label:    'Gebruikers',
              value:    '${stats.totalUsers}',
              icon:     Icons.people_rounded,
              color:    const Color(0xFF3B82F6),
              subtitle: 'Geregistreerd',
            )),
            const SizedBox(width: 16),
            Expanded(child: AdminStatCard(
              label:    'Biedingen vandaag',
              value:    '${stats.todayBids}',
              icon:     Icons.trending_up_rounded,
              color:    const Color(0xFF10B981),
              subtitle: 'Actief bieden',
            )),
            const SizedBox(width: 16),
            Expanded(child: AdminStatCard(
              label:    'Openstaande betalingen',
              value:    '${stats.pendingPayments}',
              icon:     Icons.payment_rounded,
              color:    const Color(0xFFF59E0B),
              subtitle: stats.pendingPayments > 0 ? 'Actie vereist' : 'Alles verwerkt',
              alert:    stats.pendingPayments > 5,
            )),
          ]),
          const SizedBox(height: 16),

          // Revenue stat — full width
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:     LinearGradient(
                colors: [AppColors.primaryRed, const Color(0xFFC1121F)],
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.primaryRed.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(children: [
              const Icon(Icons.euro_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(euro.format(stats.totalRevenue),
                    style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                  const Text('Totale omzet (betaalde orders)',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // ── Chart + ending soon ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bid chart
              Expanded(
                flex: 3,
                child: AdminChart(
                  title:  'Biedingen afgelopen 7 dagen',
                  points: stats.bidChart,
                ),
              ),
              const SizedBox(width: 16),
              // Ending soon
              Expanded(
                flex: 2,
                child: _EndingSoonCard(items: stats.endingSoon),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Recent bids ──────────────────────────────────────────────────────
          _RecentBidsCard(bids: stats.recentBids),
        ],
      ),
    );
  }
}

// ── Ending soon card ─────────────────────────────────────────────────────────

class _EndingSoonCard extends StatelessWidget {
  final List<EndingSoonItem> items;
  const _EndingSoonCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text('Loopt bijna af ⏳',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1D27))),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/admin/auctions'),
                  child: Text('Alles', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Geen veilingen', style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ...items.map((item) => _EndingSoonTile(item: item)),
        ],
      ),
    );
  }
}

class _EndingSoonTile extends StatelessWidget {
  final EndingSoonItem item;
  const _EndingSoonTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final remaining = item.endsAt.difference(DateTime.now());
    final isUrgent  = remaining.inMinutes < 30;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF8F8FA))),
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF1A1D27)),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${item.bidCount} biedingen · €${item.currentBid.toInt()}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6))),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        isUrgent
                ? Colors.red.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _fmt(remaining),
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: isUrgent ? Colors.red : Colors.orange,
            ),
          ),
        ),
      ]),
    );
  }

  String _fmt(Duration d) {
    if (d.inDays    >= 1) return '${d.inDays}d';
    if (d.inHours   >= 1) return '${d.inHours}u';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}

// ── Recent bids card ─────────────────────────────────────────────────────────

class _RecentBidsCard extends StatelessWidget {
  final List<RecentBidItem> bids;
  const _RecentBidsCard({required this.bids});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              const Text('Recente biedingen',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1D27))),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/admin/bids'),
                child: Text('Alles', style: TextStyle(color: AppColors.primaryRed, fontSize: 12)),
              ),
            ]),
          ),
          if (bids.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nog geen biedingen vandaag.', style: TextStyle(color: Colors.grey)),
            )
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFFFAFAFC)),
                  children: [
                    _TH('Gebruiker'),
                    _TH('Veiling'),
                    _TH('Bod'),
                    _TH('Tijdstip'),
                  ],
                ),
                ...bids.map((bid) => TableRow(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFF8F8FA))),
                  ),
                  children: [
                    _TD(bid.userName),
                    _TD(bid.auctionTitle, secondary: true),
                    _TD('€ ${bid.amount.toInt()}', bold: true),
                    _TD(DateFormat('HH:mm').format(bid.createdAt)),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Text(text, style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: Color(0xFF8B9CB6), letterSpacing: 0.5)),
  );
}

class _TD extends StatelessWidget {
  final String text;
  final bool secondary;
  final bool bold;
  const _TD(this.text, {this.secondary = false, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(text,
      maxLines: 1, overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: secondary ? const Color(0xFF8B9CB6) : const Color(0xFF1A1D27),
      )),
  );
}

// ── Refresh button ────────────────────────────────────────────────────────────

class _RefreshButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.read<AdminDashboardBloc>().add(LoadDashboardStats()),
      icon: const Icon(Icons.refresh_rounded, size: 15),
      label: const Text('Vernieuwen'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF5A6478),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
