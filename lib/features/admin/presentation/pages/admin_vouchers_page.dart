// lib/features/admin/presentation/pages/admin_vouchers_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/datasources/admin_voucher_datasource.dart';
import '../../domain/entities/admin_voucher_entity.dart';
import '../bloc/admin_voucher_bloc.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_stat_card.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBg     = Color(0xFFF8FAFC);
const _kCard   = Colors.white;
const _kBorder = Color(0xFFE2E8F0);
const _kText   = Color(0xFF1E293B);
const _kSub    = Color(0xFF64748B);
const _kAccent = Color(0xFF6366F1);

// ─────────────────────────────────────────────────────────────────────────────
class AdminVouchersPage extends StatelessWidget {
  const AdminVouchersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AdminVoucherBloc(ctx.read<AdminVoucherDatasource>())
        ..add(const LoadAdminVouchers()),
      child: const _VouchersShell(),
    );
  }
}

class _VouchersShell extends StatelessWidget {
  const _VouchersShell();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 6,
      child: BlocConsumer<AdminVoucherBloc, AdminVoucherState>(
        listenWhen: (_, s) =>
            s is AdminVoucherError || (s is AdminVoucherLoaded && s.bulkCodes != null),
        listener: (ctx, state) {
          if (state is AdminVoucherError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ));
          }
          if (state is AdminVoucherLoaded && state.bulkCodes != null) {
            _downloadCsv(
              state.bulkCodes!,
              state.bulkAuctionTitle ?? '',
              state.bulkExpiresAt ?? DateTime.now(),
            );
            ctx.read<AdminVoucherBloc>().add(const ClearBulkCodes());
          }
        },
        builder: (ctx, state) {
          if (state is AdminVoucherLoading || state is AdminVoucherInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminVoucherLoaded) {
            return _VouchersContent(state: state);
          }
          return const Center(child: Text('Laden mislukt'));
        },
      ),
    );
  }

  void _downloadCsv(List<String> codes, String title, DateTime expiresAt) {
    final exp = DateFormat('dd-MM-yyyy').format(expiresAt);
    final rows = [
      'Code,Veiling,Verloopt op',
      ...codes.map((c) => '$c,"$title",$exp'),
    ].join('\n');
    final encoded = base64Encode(utf8.encode(rows));
    final uri = Uri.parse('data:text/csv;charset=utf-8;base64,$encoded');
    launchUrl(uri);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _VouchersContent extends StatelessWidget {
  final AdminVoucherLoaded state;
  const _VouchersContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminVoucherBloc>();
    return Container(
      color: _kBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: _kCard,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vouchers',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _kText)),
                      Text('${state.stats.total} vouchers totaal',
                          style:
                              const TextStyle(fontSize: 13, color: _kSub)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Vernieuwen',
                  icon: const Icon(Icons.refresh_rounded, color: _kSub),
                  onPressed: () => bloc.add(const LoadAdminVouchers()),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Genereer voucher'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kAccent,
                    side: const BorderSide(color: _kAccent),
                  ),
                  onPressed: () => _showGenerateDialog(context),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.file_download_rounded, size: 18),
                  label: const Text('Bulk genereren'),
                  style: FilledButton.styleFrom(backgroundColor: _kAccent),
                  onPressed: () => _showBulkDialog(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _kBorder),
          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat cards
                  Row(children: [
                    Expanded(
                      child: AdminStatCard(
                        label: 'Geldig',
                        value: state.stats.validCount.toString(),
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Gebruikt',
                        value: state.stats.usedCount.toString(),
                        icon: Icons.done_all_rounded,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Verlopen',
                        value: state.stats.expiredCount.toString(),
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AdminStatCard(
                        label: 'Ingetrokken',
                        value: state.stats.revokedCount.toString(),
                        icon: Icons.block_rounded,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Filter bar
                  _FilterBar(state: state),
                  const SizedBox(height: 16),
                  // Table
                  _VouchersTable(vouchers: state.vouchers),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminVoucherBloc>(),
        child: const _GenerateDialog(),
      ),
    );
  }

  void _showBulkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminVoucherBloc>(),
        child: const _BulkDialog(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter bar
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBar extends StatefulWidget {
  final AdminVoucherLoaded state;
  const _FilterBar({required this.state});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late final TextEditingController _searchCtrl;
  VoucherStatus? _selected;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.state.search);
    _selected   = widget.state.statusFilter;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    context.read<AdminVoucherBloc>().add(FilterAdminVouchers(
          status: _selected,
          search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Status chips
          Wrap(
            spacing: 8,
            children: [
              _chip(null, 'Alle'),
              _chip(VoucherStatus.valid,   'Geldig'),
              _chip(VoucherStatus.used,    'Gebruikt'),
              _chip(VoucherStatus.expired, 'Verlopen'),
              _chip(VoucherStatus.revoked, 'Ingetrokken'),
            ],
          ),
          const Spacer(),
          // Search
          SizedBox(
            width: 240,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Zoek code, veiling, gebruiker...',
                hintStyle: const TextStyle(fontSize: 13, color: _kSub),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _kBorder)),
              ),
              onSubmitted: (_) => _apply(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Zoeken',
            icon: const Icon(Icons.arrow_forward_rounded, color: _kAccent),
            onPressed: _apply,
          ),
        ],
      ),
    );
  }

  Widget _chip(VoucherStatus? v, String label) {
    final selected = _selected == v;
    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : _kSub)),
      selected: selected,
      selectedColor: _kAccent,
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      onSelected: (_) {
        setState(() => _selected = v);
        _apply();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vouchers table
// ─────────────────────────────────────────────────────────────────────────────
class _VouchersTable extends StatelessWidget {
  final List<AdminVoucherEntity> vouchers;
  const _VouchersTable({required this.vouchers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: const Row(children: [
              SizedBox(width: 48),
              _TH('Code', flex: 2),
              _TH('Veiling', flex: 3),
              _TH('Gebruiker', flex: 3),
              _TH('Status', flex: 2),
              _TH('Verloopt', flex: 2),
              _TH('Aangemaakt', flex: 2),
              SizedBox(width: 48),
            ]),
          ),
          if (vouchers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.confirmation_number_outlined,
                    size: 40, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                const Text('Geen vouchers gevonden',
                    style: TextStyle(color: _kSub)),
              ]),
            )
          else
            ...vouchers.map((v) => _VoucherRow(voucher: v)),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String label;
  final int    flex;
  const _TH(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _kSub,
                letterSpacing: 0.5)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Voucher row
// ─────────────────────────────────────────────────────────────────────────────
class _VoucherRow extends StatelessWidget {
  final AdminVoucherEntity voucher;
  const _VoucherRow({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yy');
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: InkWell(
        onTap: () => _showQrModal(context, voucher),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            // Mini QR
            SizedBox(
              width: 48,
              child: QrImageView(
                data: voucher.qrData,
                version: QrVersions.auto,
                size: 36,
                backgroundColor: Colors.white,
              ),
            ),
            // Code
            Expanded(
              flex: 2,
              child: Text(voucher.code,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 1.5,
                      color: _kText)),
            ),
            // Auction
            Expanded(
              flex: 3,
              child: Text(voucher.auctionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _kText)),
            ),
            // User
            Expanded(
              flex: 3,
              child: voucher.userName != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(voucher.userName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: _kText)),
                        Text(voucher.userEmail ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, color: _kSub)),
                      ],
                    )
                  : const Text('—',
                      style: TextStyle(fontSize: 13, color: _kSub)),
            ),
            // Status
            Expanded(
              flex: 2,
              child: _StatusBadge(voucher.status),
            ),
            // Expiry
            Expanded(
              flex: 2,
              child: Text(
                fmt.format(voucher.expiresAt),
                style: TextStyle(
                    fontSize: 12,
                    color: voucher.isExpired
                        ? Colors.red.shade600
                        : _kSub),
              ),
            ),
            // Created
            Expanded(
              flex: 2,
              child: Text(fmt.format(voucher.createdAt),
                  style: const TextStyle(fontSize: 12, color: _kSub)),
            ),
            // Actions
            SizedBox(
              width: 48,
              child: _ActionMenu(voucher: voucher),
            ),
          ]),
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context, AdminVoucherEntity v) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminVoucherBloc>(),
        child: _QrModal(voucher: v),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final VoucherStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      VoucherStatus.valid   => (const Color(0xFFD1FAE5), const Color(0xFF065F46)),
      VoucherStatus.used    => (const Color(0xFFEDE9FE), const Color(0xFF4C1D95)),
      VoucherStatus.expired => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      VoucherStatus.revoked => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.label,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row action menu
// ─────────────────────────────────────────────────────────────────────────────
class _ActionMenu extends StatelessWidget {
  final AdminVoucherEntity voucher;
  const _ActionMenu({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminVoucherBloc>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: _kSub),
      itemBuilder: (_) => [
        if (voucher.status == VoucherStatus.valid) ...[
          const PopupMenuItem(value: 'used',    child: Text('Markeer gebruikt')),
          const PopupMenuItem(value: 'revoked', child: Text('Intrekken')),
        ],
        if (voucher.status == VoucherStatus.used)
          const PopupMenuItem(value: 'valid', child: Text('Herstel naar geldig')),
        const PopupMenuItem(value: 'qr', child: Text('QR code bekijken')),
      ],
      onSelected: (action) {
        if (action == 'qr') {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: _QrModal(voucher: voucher),
            ),
          );
          return;
        }
        final newStatus = switch (action) {
          'used'    => VoucherStatus.used,
          'revoked' => VoucherStatus.revoked,
          _         => VoucherStatus.valid,
        };
        _confirmStatusChange(context, bloc, newStatus);
      },
    );
  }

  void _confirmStatusChange(
      BuildContext context, AdminVoucherBloc bloc, VoucherStatus newStatus) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Status wijzigen'),
        content:
            Text('Verander status naar "${newStatus.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kAccent),
            onPressed: () {
              Navigator.pop(context);
              bloc.add(UpdateAdminVoucherStatus(
                voucherId: voucher.id,
                newStatus: newStatus,
                adminId:   '',
                adminName: '',
              ));
            },
            child: const Text('Bevestigen'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR modal
// ─────────────────────────────────────────────────────────────────────────────
class _QrModal extends StatelessWidget {
  final AdminVoucherEntity voucher;
  const _QrModal({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMMM yyyy', 'nl');
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('QR Code',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kText)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: QrImageView(
                data: voucher.qrData,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(voucher.code,
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: _kText)),
            const SizedBox(height: 4),
            Text(voucher.auctionTitle,
                style: const TextStyle(fontSize: 13, color: _kSub)),
            const SizedBox(height: 4),
            _StatusBadge(voucher.status),
            const SizedBox(height: 4),
            Text('Verloopt: ${fmt.format(voucher.expiresAt)}',
                style: const TextStyle(fontSize: 12, color: _kSub)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Kopieer code'),
                  style: OutlinedButton.styleFrom(foregroundColor: _kAccent),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: voucher.code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Code gekopieerd'),
                        duration: Duration(seconds: 2)));
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Afdrukken'),
                  style: OutlinedButton.styleFrom(foregroundColor: _kSub),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Gebruik de browser printfunctie (Ctrl+P / Cmd+P)'),
                        duration: Duration(seconds: 3)));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generate single voucher dialog
// ─────────────────────────────────────────────────────────────────────────────
class _GenerateDialog extends StatefulWidget {
  const _GenerateDialog();

  @override
  State<_GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<_GenerateDialog> {
  ({String id, String title})? _auction;
  String? _userId;
  String? _userName;
  String? _userEmail;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 90));
  bool _loading = false;
  String? _error;

  final _searchCtrl = TextEditingController();
  List<({String uid, String name, String email})> _userResults = [];
  bool _searchingUsers = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String q) async {
    if (q.length < 2) {
      setState(() => _userResults = []);
      return;
    }
    setState(() => _searchingUsers = true);
    try {
      final ds = context.read<AdminVoucherDatasource>();
      final r  = await ds.searchUsers(q);
      setState(() {
        _userResults    = r;
        _searchingUsers = false;
      });
    } catch (_) {
      setState(() => _searchingUsers = false);
    }
  }

  Future<void> _submit() async {
    if (_auction == null) {
      setState(() => _error = 'Selecteer een veiling');
      return;
    }
    setState(() {
      _loading = true;
      _error   = null;
    });
    try {
      context.read<AdminVoucherBloc>().add(GenerateAdminVoucher(
            auctionId:    _auction!.id,
            auctionTitle: _auction!.title,
            userId:       _userId,
            userName:     _userName,
            userEmail:    _userEmail,
            expiresAt:    _expiresAt,
          ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error   = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.read<AdminVoucherDatasource>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Voucher genereren',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kText)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 20),

            // Auction picker
            const Text('Veiling *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kSub)),
            const SizedBox(height: 6),
            FutureBuilder<List<({String id, String title})>>(
              future: ds.getLiveAuctions(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 48,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)));
                }
                return DropdownButtonFormField<String>(
                  initialValue: _auction?.id,
                  hint: const Text('Selecteer een veiling'),
                  decoration: _inputDec(),
                  items: snap.data!
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.title,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final a = snap.data!.firstWhere((x) => x.id == id);
                    setState(() => _auction = a);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // User search (optional)
            const Text('Gebruiker (optioneel)',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kSub)),
            const SizedBox(height: 6),
            if (_userId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _kText)),
                          Text(_userEmail ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: _kSub)),
                        ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: _kSub),
                    onPressed: () => setState(() {
                      _userId    = null;
                      _userName  = null;
                      _userEmail = null;
                    }),
                  ),
                ]),
              )
            else ...[
              TextField(
                controller: _searchCtrl,
                decoration: _inputDec(
                    hint: 'Zoek gebruiker op naam...',
                    suffix: _searchingUsers
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
                        : null),
                onChanged: _searchUsers,
              ),
              if (_userResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: _userResults
                        .map((u) => ListTile(
                              dense: true,
                              title: Text(u.name,
                                  style: const TextStyle(fontSize: 13)),
                              subtitle: Text(u.email,
                                  style: const TextStyle(fontSize: 11)),
                              onTap: () => setState(() {
                                _userId    = u.uid;
                                _userName  = u.name;
                                _userEmail = u.email;
                                _userResults = [];
                                _searchCtrl.clear();
                              }),
                            ))
                        .toList(),
                  ),
                ),
            ],
            const SizedBox(height: 16),

            // Expiry date
            const Text('Vervaldatum *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kSub)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt,
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null) setState(() => _expiresAt = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: _kSub),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_expiresAt),
                    style: const TextStyle(color: _kText),
                  ),
                ]),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(
                      color: Colors.red.shade600, fontSize: 12)),
            ],
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuleren')),
                const SizedBox(width: 8),
                FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: _kAccent),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : const Text('Genereer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bulk generate dialog
// ─────────────────────────────────────────────────────────────────────────────
class _BulkDialog extends StatefulWidget {
  const _BulkDialog();

  @override
  State<_BulkDialog> createState() => _BulkDialogState();
}

class _BulkDialogState extends State<_BulkDialog> {
  ({String id, String title})? _auction;
  int      _quantity = 10;
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 90));
  bool     _loading  = false;
  String?  _error;

  Future<void> _submit() async {
    if (_auction == null) {
      setState(() => _error = 'Selecteer een veiling');
      return;
    }
    setState(() {
      _loading = true;
      _error   = null;
    });
    context.read<AdminVoucherBloc>().add(BulkGenerateAdminVouchers(
          auctionId:    _auction!.id,
          auctionTitle: _auction!.title,
          quantity:     _quantity,
          expiresAt:    _expiresAt,
        ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.read<AdminVoucherDatasource>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('Bulk vouchers genereren',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _kText)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ]),
            const SizedBox(height: 8),
            const Text(
              'Genereer meerdere anonieme vouchers en download ze als CSV.',
              style: TextStyle(fontSize: 13, color: _kSub),
            ),
            const SizedBox(height: 20),

            // Auction
            const Text('Veiling *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kSub)),
            const SizedBox(height: 6),
            FutureBuilder<List<({String id, String title})>>(
              future: ds.getLiveAuctions(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                      height: 48,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)));
                }
                return DropdownButtonFormField<String>(
                  initialValue: _auction?.id,
                  hint: const Text('Selecteer een veiling'),
                  decoration: _inputDec(),
                  items: snap.data!
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.title,
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final a = snap.data!.firstWhere((x) => x.id == id);
                    setState(() => _auction = a);
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Quantity slider
            Row(children: [
              const Text('Aantal: ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kSub)),
              Text('$_quantity',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _kAccent)),
            ]),
            Slider(
              value: _quantity.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: _kAccent,
              label: '$_quantity',
              onChanged: (v) => setState(() => _quantity = v.round()),
            ),
            const SizedBox(height: 8),

            // Expiry
            const Text('Vervaldatum *',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kSub)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt,
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null) setState(() => _expiresAt = d);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: _kSub),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_expiresAt),
                    style: const TextStyle(color: _kText),
                  ),
                ]),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(
                      color: Colors.red.shade600, fontSize: 12)),
            ],
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuleren')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style:
                      FilledButton.styleFrom(backgroundColor: _kAccent),
                  icon: const Icon(Icons.file_download_rounded, size: 18),
                  label: Text(_loading
                      ? 'Bezig...'
                      : 'Genereer & download CSV'),
                  onPressed: _loading ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────
InputDecoration _inputDec({String? hint, Widget? suffix}) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: _kSub),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _kAccent)),
    );
