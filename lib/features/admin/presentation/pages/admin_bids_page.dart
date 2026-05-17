import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bids_bloc.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_stat_card.dart';
import '../../domain/entities/admin_bid_entity.dart';
import '../../data/datasources/admin_bids_datasource.dart';
import '../../../../core/constants/app_colors.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class AdminBidsPage extends StatelessWidget {
  const AdminBidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          AdminBidsBloc(ctx.read<AdminBidsDatasource>())
            ..add(const LoadAdminBids()),
      child: const AdminShell(selectedIndex: 4, child: _BidsBody()),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _BidsBody extends StatelessWidget {
  const _BidsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBidsBloc, AdminBidsState>(
      builder: (context, state) {
        if (state is AdminBidsInitial || state is AdminBidsLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed));
        }
        if (state is AdminBidsError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.message,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<AdminBidsBloc>().add(const LoadAdminBids()),
                child: const Text('Opnieuw proberen'),
              ),
            ]),
          );
        }
        if (state is AdminBidsLoaded) return _BidsContent(state: state);
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _BidsContent extends StatelessWidget {
  final AdminBidsLoaded state;
  const _BidsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final euro = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Biedingen',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color(0xFF1A1D27))),
              SizedBox(height: 2),
              Text('Overzicht van alle biedingen op alle veilingen',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
            ]),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<AdminBidsBloc>().add(const LoadAdminBids()),
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Vernieuwen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A6478),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // Stats
          Row(children: [
            Expanded(
                child: AdminStatCard(
              label:    'Totaal biedingen',
              value:    '${state.stats.totalBids}',
              icon:     Icons.gavel_rounded,
              color:    AppColors.primaryRed,
              subtitle: 'Alle biedingen',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'Vandaag',
              value:    '${state.stats.todayBids}',
              icon:     Icons.today_rounded,
              color:    const Color(0xFF3B82F6),
              subtitle: 'Biedingen vandaag',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'Hoogste bod',
              value:    euro.format(state.stats.highestBid),
              icon:     Icons.trending_up_rounded,
              color:    const Color(0xFF10B981),
              subtitle: 'Ooit geplaatst',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'Live veilingen',
              value:    '${state.stats.activeAuctions}',
              icon:     Icons.live_tv_rounded,
              color:    const Color(0xFFF59E0B),
              subtitle: 'Momenteel actief',
            )),
          ]),
          const SizedBox(height: 24),

          // Filter bar
          _FilterBar(currentSearch: state.search),
          const SizedBox(height: 16),

          // Bids table
          _BidsTable(bids: state.bids),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatefulWidget {
  final String currentSearch;
  const _FilterBar({this.currentSearch = ''});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.currentSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 280,
        child: TextField(
          controller: _search,
          onChanged: (v) => context
              .read<AdminBidsBloc>()
              .add(FilterAdminBids(search: v)),
          decoration: InputDecoration(
            hintText: 'Zoek op gebruiker of veiling…',
            hintStyle:
                const TextStyle(fontSize: 12, color: Color(0xFF8B9CB6)),
            prefixIcon: const Icon(Icons.search_rounded,
                size: 18, color: Color(0xFF8B9CB6)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryRed)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
      const SizedBox(width: 8),
      if (_search.text.isNotEmpty)
        TextButton.icon(
          onPressed: () {
            _search.clear();
            context.read<AdminBidsBloc>().add(const FilterAdminBids());
          },
          icon: const Icon(Icons.clear, size: 15),
          label: const Text('Wis', style: TextStyle(fontSize: 13)),
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B9CB6)),
        ),
    ]);
  }
}

// ── Bids table ────────────────────────────────────────────────────────────────

class _BidsTable extends StatelessWidget {
  final List<AdminBidEntity> bids;
  const _BidsTable({required this.bids});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text('${bids.length} biedingen',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1D27))),
          ),
          const SizedBox(height: 8),
          Container(
            color: const Color(0xFFFAFAFC),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              Expanded(flex: 2, child: _TH('Gebruiker')),
              Expanded(flex: 3, child: _TH('Veiling')),
              SizedBox(width: 112, child: _TH('Bod')),
              SizedBox(width: 140, child: _TH('Tijdstip')),
            ]),
          ),
          if (bids.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Geen biedingen gevonden.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ...bids.map((b) => _BidRow(bid: b)),
        ],
      ),
    );
  }
}

class _BidRow extends StatelessWidget {
  final AdminBidEntity bid;
  const _BidRow({required this.bid});

  @override
  Widget build(BuildContext context) {
    final dtFmt = DateFormat('dd/MM/yy HH:mm');
    final euro  = NumberFormat.currency(
        locale: 'nl_NL', symbol: '€', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF8F8FA))),
      ),
      child: Row(children: [
        Expanded(
            flex: 2,
            child: Row(children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryRed.withValues(alpha: 0.1),
                child: Text(
                  bid.userName.isNotEmpty
                      ? bid.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(bid.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D27)))),
            ])),
        Expanded(
            flex: 3,
            child: Text(bid.auctionTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF5A6478)))),
        SizedBox(
            width: 112,
            child: Text(euro.format(bid.amount),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D27)))),
        SizedBox(
            width: 140,
            child: Text(dtFmt.format(bid.createdAt),
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF8B9CB6)))),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B9CB6),
          letterSpacing: 0.5));
}
