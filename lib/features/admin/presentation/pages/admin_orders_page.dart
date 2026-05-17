// lib/features/admin/presentation/pages/admin_orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_routes.dart';
import '../bloc/admin_order_bloc.dart';
import '../bloc/admin_auth_bloc.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_chart.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../data/datasources/admin_order_datasource.dart';
import '../../../../core/constants/app_colors.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AdminOrderBloc(ctx.read<AdminOrderDatasource>())
        ..add(LoadAdminOrders()),
      child: const AdminShell(selectedIndex: 5, child: _OrdersBody()),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _OrdersBody extends StatelessWidget {
  const _OrdersBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminOrderBloc, AdminOrderState>(
      listener: (context, state) {
        if (state is AdminOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is AdminOrderInitial || state is AdminOrderLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed));
        }
        if (state is AdminOrderError) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.message,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<AdminOrderBloc>().add(LoadAdminOrders()),
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ));
        }
        if (state is AdminOrderLoaded) return _OrdersContent(state: state);
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _OrdersContent extends StatelessWidget {
  final AdminOrderLoaded state;
  const _OrdersContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final euro =
        NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
    final euro2 =
        NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Betalingen',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Color(0xFF1A1D27))),
                  SizedBox(height: 2),
                  Text('Overzicht van alle bestellingen en betalingsstatus',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
                ]),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<AdminOrderBloc>().add(LoadAdminOrders()),
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
          const SizedBox(height: 16),

          // Expiry warning
          if (state.stats.expiringCount > 0)
            _ExpireWarningBanner(count: state.stats.expiringCount),

          // Stats
          Row(children: [
            Expanded(
                child: AdminStatCard(
              label: 'Totale omzet',
              value: euro.format(state.stats.totalRevenue),
              icon: Icons.euro_rounded,
              color: const Color(0xFF10B981),
              subtitle: 'Alle betaalde orders',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label: 'In afwachting',
              value: '${state.stats.pendingCount}',
              icon: Icons.hourglass_empty_rounded,
              color: const Color(0xFFF59E0B),
              subtitle: state.stats.pendingCount > 0
                  ? 'Actie vereist'
                  : 'Alles verwerkt',
              alert: state.stats.pendingCount > 0,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label: 'Mislukt',
              value: '${state.stats.failedCount}',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFEF4444),
              subtitle: state.stats.failedCount > 0
                  ? 'Controleer orders'
                  : 'Geen fouten',
              alert: state.stats.failedCount > 0,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label: 'Terugbetaald',
              value: euro2.format(state.stats.refundedTotal),
              icon: Icons.replay_rounded,
              color: const Color(0xFF3B82F6),
              subtitle: 'Totaal terugbetaald',
            )),
          ]),
          const SizedBox(height: 24),

          // Revenue chart
          AdminChart(
              title: 'Omzet afgelopen 10 dagen', points: state.revenueChart),
          const SizedBox(height: 24),

          // Filter bar
          _FilterBar(
              currentFilter: state.statusFilter, currentSearch: state.search),
          const SizedBox(height: 16),

          // Table + side panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _OrdersTable(orders: state.orders)),
              if (state.selectedOrder != null) ...[
                const SizedBox(width: 16),
                SizedBox(
                  width: 376,
                  child: _OrderDetailPanel(order: state.selectedOrder!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Expire warning ────────────────────────────────────────────────────────────

class _ExpireWarningBanner extends StatelessWidget {
  final int count;
  const _ExpireWarningBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
          '$count bestelling${count > 1 ? 'en' : ''} staat al meer dan 20 uur '
          'open en vervalt binnenkort. Controleer deze bestellingen.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
        )),
        TextButton(
          onPressed: () => context
              .read<AdminOrderBloc>()
              .add(const FilterAdminOrders(status: OrderStatus.pending)),
          child: const Text('Bekijk'),
        ),
      ]),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatefulWidget {
  final OrderStatus? currentFilter;
  final String currentSearch;
  const _FilterBar({this.currentFilter, this.currentSearch = ''});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late final TextEditingController _search;
  OrderStatus? _status;
  DateTimeRange? _range;

  static const _opts = [
    (null, 'Alle'),
    (OrderStatus.pending, 'Afwachting'),
    (OrderStatus.paid, 'Betaald'),
    (OrderStatus.failed, 'Mislukt'),
    (OrderStatus.cancelled, 'Geannuleerd'),
    (OrderStatus.refunded, 'Terugbetaald'),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.currentFilter;
    _search = TextEditingController(text: widget.currentSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _apply() => context.read<AdminOrderBloc>().add(FilterAdminOrders(
        status: _status,
        search: _search.text,
        from: _range?.start,
        to: _range?.end,
      ));

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (s, label) in _opts)
          FilterChip(
            label: Text(label),
            selected: _status == s,
            onSelected: (_) {
              setState(() => _status = s);
              _apply();
            },
            selectedColor: AppColors.primaryRed.withValues(alpha: 0.12),
            checkmarkColor: AppColors.primaryRed,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _status == s ? FontWeight.w700 : FontWeight.w500,
              color:
                  _status == s ? AppColors.primaryRed : const Color(0xFF5A6478),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(
              color: _status == s
                  ? AppColors.primaryRed.withValues(alpha: 0.3)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        if (_range != null)
          Chip(
            label: Text(
                '${DateFormat('dd/MM').format(_range!.start)} – '
                '${DateFormat('dd/MM').format(_range!.end)}',
                style: const TextStyle(fontSize: 11)),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () {
              setState(() => _range = null);
              _apply();
            },
          ),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
              initialDateRange: _range,
            );
            if (picked != null) {
              setState(() => _range = picked);
              _apply();
            }
          },
          icon: const Icon(Icons.date_range_rounded, size: 15),
          label: const Text('Datum'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5A6478),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _search,
            onChanged: (_) => _apply(),
            decoration: InputDecoration(
              hintText: 'Zoek order, gebruiker...',
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
      ],
    );
  }
}

// ── Orders table ──────────────────────────────────────────────────────────────

class _OrdersTable extends StatelessWidget {
  final List<AdminOrderEntity> orders;
  const _OrdersTable({required this.orders});

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
            child: Text('${orders.length} bestellingen',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1D27))),
          ),
          const SizedBox(height: 8),

          // Header
          Container(
            color: const Color(0xFFFAFAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              SizedBox(width: 84, child: _TH('Order')),
              Expanded(flex: 3, child: _TH('Veiling')),
              Expanded(flex: 2, child: _TH('Gebruiker')),
              SizedBox(width: 96, child: _TH('Bedrag')),
              SizedBox(width: 100, child: _TH('Methode')),
              SizedBox(width: 118, child: _TH('Status')),
              SizedBox(width: 108, child: _TH('Datum')),
              SizedBox(width: 36),
            ]),
          ),

          if (orders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Geen bestellingen gevonden.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ...orders.map((o) => _OrderRow(order: o)),
        ],
      ),
    );
  }
}

// ── Order row ─────────────────────────────────────────────────────────────────

class _OrderRow extends StatelessWidget {
  final AdminOrderEntity order;
  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<AdminOrderBloc, bool>((b) {
      final s = b.state;
      return s is AdminOrderLoaded && s.selectedOrder?.id == order.id;
    });
    final dtFmt = DateFormat('dd/MM/yy HH:mm');

    return InkWell(
      onTap: () => context
          .read<AdminOrderBloc>()
          .add(SelectAdminOrder(isSelected ? null : order)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.04)
              : Colors.transparent,
          border: const Border(top: BorderSide(color: Color(0xFFF8F8FA))),
        ),
        child: Row(children: [
          SizedBox(
              width: 84,
              child: Text(order.shortId,
                  style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A6478)))),
          Expanded(
              flex: 3,
              child: Text(order.auctionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D27)))),
          Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1D27))),
                  Text(order.userEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF8B9CB6))),
                ],
              )),
          SizedBox(
              width: 96,
              child: Text(
                  NumberFormat.currency(
                          locale: 'nl_NL', symbol: '€', decimalDigits: 2)
                      .format(order.amount),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1D27)))),
          SizedBox(
              width: 100,
              child: Text(order.paymentMethod ?? '—',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF5A6478)))),
          SizedBox(width: 118, child: _StatusBadge(status: order.status)),
          SizedBox(
              width: 108,
              child: Text(dtFmt.format(order.createdAt),
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF5A6478)))),
          SizedBox(width: 36, child: _ActionMenu(order: order)),
        ]),
      ),
    );
  }
}

// ── Action menu ───────────────────────────────────────────────────────────────

class _ActionMenu extends StatelessWidget {
  final AdminOrderEntity order;
  const _ActionMenu({required this.order});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AdminAuthBloc>().state;
    final admin = authState is AdminAuthenticated ? authState.user : null;
    final isSuperAdmin = admin?.role == AdminRole.superAdmin;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded,
          size: 18, color: Color(0xFF8B9CB6)),
      itemBuilder: (_) => [
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.failed)
          const PopupMenuItem(value: 'pay', child: Text('Markeer als betaald')),
        if (order.status == OrderStatus.pending)
          const PopupMenuItem(
              value: 'remind', child: Text('Stuur herinnering')),
        if (order.status == OrderStatus.pending ||
            order.status == OrderStatus.failed)
          const PopupMenuItem(value: 'cancel', child: Text('Annuleren')),
        if (order.status == OrderStatus.paid && isSuperAdmin)
          const PopupMenuItem(value: 'refund', child: Text('Terugbetalen')),
        const PopupMenuItem(value: 'voucher', child: Text('Bekijk voucher')),
      ],
      onSelected: (v) => _onAction(context, v, admin),
    );
  }

  Future<void> _onAction(
      BuildContext context, String action, AdminUserEntity? admin) async {
    if (admin == null) return;
    final bloc = context.read<AdminOrderBloc>();

    if (action == 'voucher') {
      context.go(AppRoutes.adminVouchers);
      return;
    }
    if (action == 'remind') {
      bloc.add(SendAdminPaymentReminder(
          userId: order.userId, auctionTitle: order.auctionTitle));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Herinnering verzonden'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    OrderStatus newStatus;
    String title;
    String body;

    if (action == 'pay') {
      newStatus = OrderStatus.paid;
      title = 'Betaling bevestigen';
      body = 'Weet je zeker dat je deze order als betaald wilt markeren?';
    } else if (action == 'cancel') {
      newStatus = OrderStatus.cancelled;
      title = 'Order annuleren';
      body = 'Weet je zeker dat je deze order wilt annuleren?';
    } else if (action == 'refund') {
      newStatus = OrderStatus.refunded;
      title = 'Terugbetaling';
      body = 'Weet je zeker dat je '
          '${NumberFormat.currency(locale: "nl_NL", symbol: "€", decimalDigits: 2).format(order.amount)} '
          'wilt terugbetalen?';
    } else {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuleren')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bevestigen'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      bloc.add(UpdateAdminOrderStatus(
        orderId: order.id,
        newStatus: newStatus,
        adminId: admin.id,
        adminName: admin.displayName,
      ));
    }
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  Color _color() => switch (status) {
        OrderStatus.pending => const Color(0xFFF59E0B),
        OrderStatus.paid => const Color(0xFF10B981),
        OrderStatus.failed => const Color(0xFFEF4444),
        OrderStatus.cancelled => const Color(0xFF6B7280),
        OrderStatus.refunded => const Color(0xFF3B82F6),
      };

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Text(status.label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)),
    );
  }
}

// ── Order detail panel ────────────────────────────────────────────────────────

class _OrderDetailPanel extends StatelessWidget {
  final AdminOrderEntity order;
  const _OrderDetailPanel({required this.order});

  @override
  Widget build(BuildContext context) {
    final euro =
        NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 2);
    final dtFmt = DateFormat('dd MMM yyyy, HH:mm', 'nl_NL');
    final bloc = context.read<AdminOrderBloc>();
    final auth = context.watch<AdminAuthBloc>().state;
    final admin = auth is AdminAuthenticated ? auth.user : null;
    final isSA = admin?.role == AdminRole.superAdmin;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${order.shortId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          fontFamily: 'monospace',
                          color: Color(0xFF1A1D27))),
                  const SizedBox(height: 6),
                  _StatusBadge(status: order.status),
                ],
              )),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF8B9CB6)),
                onPressed: () => bloc.add(const SelectAdminOrder(null)),
              ),
            ]),
          ),
          const Divider(height: 20),

          // Order info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('Veiling', order.auctionTitle),
                _Row('Gebruiker', '${order.userName}\n${order.userEmail}'),
                _Row('Bedrag', euro.format(order.amount), bold: true),
                _Row('Aangemaakt', dtFmt.format(order.createdAt)),
                _Row('Betaald op',
                    order.paidAt != null ? dtFmt.format(order.paidAt!) : '—'),
                _Row('Vervalt', _expiryText()),
              ],
            ),
          ),
          const Divider(height: 20),

          // Mollie payment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Betaling',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1A1D27))),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: Text(
                    order.molliePaymentId.isEmpty ? '—' : order.molliePaymentId,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF5A6478)),
                    overflow: TextOverflow.ellipsis,
                  )),
                  if (order.molliePaymentId.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          size: 14, color: Color(0xFF8B9CB6)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Kopiëren',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: order.molliePaymentId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Betaling-ID gekopieerd'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ]),
                if (order.paymentMethod != null)
                  Text(order.paymentMethod!,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF8B9CB6))),
              ],
            ),
          ),
          const Divider(height: 20),

          // Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tijdlijn',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF1A1D27))),
                const SizedBox(height: 10),
                _Step('Aangemaakt', dtFmt.format(order.createdAt),
                    done: true, last: false),
                _Step(
                    'In behandeling',
                    order.status != OrderStatus.pending
                        ? dtFmt.format(order.createdAt)
                        : 'Wachtend...',
                    done: order.status != OrderStatus.pending,
                    last: false),
                _Step(
                    order.status == OrderStatus.refunded
                        ? 'Terugbetaald'
                        : order.status == OrderStatus.failed
                            ? 'Mislukt'
                            : order.status == OrderStatus.cancelled
                                ? 'Geannuleerd'
                                : 'Betaald',
                    order.paidAt != null ? dtFmt.format(order.paidAt!) : '—',
                    done: order.status == OrderStatus.paid ||
                        order.status == OrderStatus.refunded,
                    error: order.status == OrderStatus.failed ||
                        order.status == OrderStatus.cancelled,
                    last: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (order.status == OrderStatus.failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.send_rounded, size: 15),
                      label: const Text('Stuur herinnering'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        bloc.add(SendAdminPaymentReminder(
                          userId: order.userId,
                          auctionTitle: order.auctionTitle,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Herinnering verzonden'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                if (order.status == OrderStatus.pending ||
                    order.status == OrderStatus.failed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirm(
                        context,
                        admin,
                        bloc,
                        OrderStatus.paid,
                        'Betaling bevestigen',
                        'Weet je zeker dat je deze order als betaald wilt markeren?'),
                    child: const Text('Markeer als betaald',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                if (order.status == OrderStatus.paid && isSA)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _confirm(
                          context,
                          admin,
                          bloc,
                          OrderStatus.refunded,
                          'Terugbetaling',
                          'Weet je zeker dat je deze order wilt terugbetalen?'),
                      child: const Text('Terugbetalen',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                if (order.status == OrderStatus.pending ||
                    order.status == OrderStatus.failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _confirm(
                          context,
                          admin,
                          bloc,
                          OrderStatus.cancelled,
                          'Order annuleren',
                          'Weet je zeker dat je deze order wilt annuleren?'),
                      child: const Text('Annuleren',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    AdminUserEntity? admin,
    AdminOrderBloc bloc,
    OrderStatus newStatus,
    String title,
    String body,
  ) async {
    if (admin == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuleren')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bevestigen'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      bloc.add(UpdateAdminOrderStatus(
        orderId: order.id,
        newStatus: newStatus,
        adminId: admin.id,
        adminName: admin.displayName,
      ));
    }
  }

  String _expiryText() {
    if (order.status != OrderStatus.pending) return '—';
    final d = order.timeToExpiry;
    if (d.isNegative) return 'Verlopen';
    if (d.inHours >= 1) {
      return 'Over ${d.inHours}u ${d.inMinutes.remainder(60)}m';
    }
    return 'Over ${d.inMinutes}m';
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 84,
              child: Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6)))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF1A1D27)))),
        ]),
      );
}

class _Step extends StatelessWidget {
  final String label, time;
  final bool done, error, last;
  const _Step(this.label, this.time,
      {required this.done, required this.last, this.error = false});

  @override
  Widget build(BuildContext context) {
    final c = error
        ? Colors.red
        : done
            ? const Color(0xFF10B981)
            : const Color(0xFFCBD5E1);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        if (!last)
          Container(width: 2, height: 26, color: const Color(0xFFE2E8F0)),
      ]),
      const SizedBox(width: 8),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D27))),
          Text(time,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8B9CB6))),
        ]),
      )),
    ]);
  }
}

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
