import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_auction_list_bloc.dart';
import '../widgets/admin_shell.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_auction_datasource.dart';
import '../../../../core/constants/app_colors.dart';
import 'admin_auction_form_page.dart';

class AdminAuctionsPage extends StatelessWidget {
  const AdminAuctionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAuctionListBloc(
        context.read<AdminAuctionDatasource>())..add(LoadAdminAuctions()),
      child: AdminShell(
        selectedIndex: 1,
        child: const _AuctionListBody(),
      ),
    );
  }
}

class _AuctionListBody extends StatefulWidget {
  const _AuctionListBody();
  @override State<_AuctionListBody> createState() => _AuctionListBodyState();
}

class _AuctionListBodyState extends State<_AuctionListBody> {
  AuctionStatus?   _statusFilter;
  AuctionCategory? _categoryFilter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _applyFilter() {
    context.read<AdminAuctionListBloc>().add(FilterAdminAuctions(
      status:   _statusFilter,
      category: _categoryFilter,
      search:   _searchCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Veilingen', style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 22,
                  color: Color(0xFF1A1D27))),
                SizedBox(height: 2),
                Text('Beheer alle veilingen, aanmaken & bewerken',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _openForm(context, null),
              icon:  const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nieuwe veiling'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Filters ───────────────────────────────────────────────────────
          _FilterBar(
            searchCtrl:      _searchCtrl,
            statusFilter:    _statusFilter,
            categoryFilter:  _categoryFilter,
            onStatusChanged: (v) { setState(() => _statusFilter   = v); _applyFilter(); },
            onCategoryChanged:(v) { setState(() => _categoryFilter = v); _applyFilter(); },
            onSearch:        (_)  => _applyFilter(),
            onClear: () {
              setState(() { _statusFilter = null; _categoryFilter = null; });
              _searchCtrl.clear();
              _applyFilter();
            },
          ),
          const SizedBox(height: 16),

          // ── Table ─────────────────────────────────────────────────────────
          BlocBuilder<AdminAuctionListBloc, AdminAuctionListState>(
            builder: (context, state) {
              if (state is AdminAuctionListLoading ||
                  state is AdminAuctionListInitial) {
                return const Center(
                  heightFactor: 5,
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                );
              }
              if (state is AdminAuctionListError) {
                return Center(
                  heightFactor: 5,
                  child: Text(state.message,
                    style: const TextStyle(color: Colors.red)),
                );
              }
              if (state is AdminAuctionListLoaded) {
                if (state.auctions.isEmpty) {
                  return _EmptyState(
                    onAdd: () => _openForm(context, null));
                }
                return _AuctionTable(
                  auctions: state.auctions,
                  onEdit:   (a) => _openForm(context, a),
                  onDelete: (a) => _confirmDelete(context, a),
                  onStatus: (a, s) => context.read<AdminAuctionListBloc>()
                      .add(ChangeAuctionStatus(a.id, s)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, AdminAuctionEntity? auction) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RepositoryProvider.value(
        value: context.read<AdminAuctionDatasource>(),
        child: AdminAuctionFormPage(existing: auction),
      ),
    )).then((_) {
      // Refresh list after returning from form
      if (mounted) {
        context.read<AdminAuctionListBloc>().add(LoadAdminAuctions());
      }
    });
  }

  void _confirmDelete(BuildContext context, AdminAuctionEntity auction) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:       const Text('Veiling verwijderen?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content:     Text(
          '"${auction.title}"\nDeze actie kan niet ongedaan worden gemaakt.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF5A6478))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminAuctionListBloc>()
                  .add(DeleteAdminAuction(auction.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation:       0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final AuctionStatus?        statusFilter;
  final AuctionCategory?      categoryFilter;
  final ValueChanged<AuctionStatus?>   onStatusChanged;
  final ValueChanged<AuctionCategory?> onCategoryChanged;
  final ValueChanged<String>           onSearch;
  final VoidCallback                   onClear;

  const _FilterBar({
    required this.searchCtrl,
    required this.statusFilter,
    required this.categoryFilter,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Row(children: [
        // Search
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: searchCtrl,
              onSubmitted: onSearch,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText:        'Zoek op titel of locatie…',
                hintStyle:       const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
                prefixIcon:      const Icon(Icons.search, size: 17, color: Color(0xFF8B9CB6)),
                filled:          true,
                fillColor:       const Color(0xFFF8F9FC),
                border:          OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   BorderSide.none,
                ),
                contentPadding:  const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Status filter
        _DropdownFilter<AuctionStatus>(
          value:    statusFilter,
          hint:     'Status',
          items: [
            ...AuctionStatus.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s.label, style: const TextStyle(fontSize: 13)),
            )),
          ],
          onChanged: onStatusChanged,
        ),
        const SizedBox(width: 10),

        // Category filter
        _DropdownFilter<AuctionCategory>(
          value:    categoryFilter,
          hint:     'Categorie',
          items: [
            ...AuctionCategory.values.map((c) => DropdownMenuItem(
              value: c,
              child: Text('${c.emoji} ${c.label}',
                style: const TextStyle(fontSize: 13)),
            )),
          ],
          onChanged: onCategoryChanged,
        ),
        const SizedBox(width: 10),

        // Clear
        if (statusFilter != null || categoryFilter != null || searchCtrl.text.isNotEmpty)
          TextButton.icon(
            onPressed: onClear,
            icon:  const Icon(Icons.clear, size: 15),
            label: const Text('Wis', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B9CB6)),
          ),
      ]),
    );
  }
}

class _DropdownFilter<T> extends StatelessWidget {
  final T?                        value;
  final String                    hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>          onChanged;

  const _DropdownFilter({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:        const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value:       value,
          hint:        Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF8B9CB6))),
          items:       items,
          onChanged:   onChanged,
          icon:        const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF8B9CB6)),
          isDense:     true,
          style:       const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
        ),
      ),
    );
  }
}

// ── Auction table ─────────────────────────────────────────────────────────────

class _AuctionTable extends StatelessWidget {
  final List<AdminAuctionEntity>          auctions;
  final void Function(AdminAuctionEntity) onEdit;
  final void Function(AdminAuctionEntity) onDelete;
  final void Function(AdminAuctionEntity, AuctionStatus) onStatus;

  const _AuctionTable({
    required this.auctions,
    required this.onEdit,
    required this.onDelete,
    required this.onStatus,
  });

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
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color:        Color(0xFFFAFAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(children: [
              SizedBox(width: 52),
              Expanded(flex: 4, child: _TH('Veiling')),
              Expanded(flex: 2, child: _TH('Categorie')),
              Expanded(flex: 1, child: _TH('Status')),
              Expanded(flex: 1, child: _TH('Huidig bod')),
              Expanded(flex: 1, child: _TH('Biedingen')),
              Expanded(flex: 2, child: _TH('Einddatum')),
              SizedBox(width: 100),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),

          // Rows
          ListView.separated(
            shrinkWrap:    true,
            physics:       const NeverScrollableScrollPhysics(),
            itemCount:     auctions.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF8F8FA)),
            itemBuilder:   (context, i) => _AuctionRow(
              auction:  auctions[i],
              onEdit:   () => onEdit(auctions[i]),
              onDelete: () => onDelete(auctions[i]),
              onStatus: (s) => onStatus(auctions[i], s),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionRow extends StatelessWidget {
  final AdminAuctionEntity   auction;
  final VoidCallback         onEdit;
  final VoidCallback         onDelete;
  final ValueChanged<AuctionStatus> onStatus;

  const _AuctionRow({
    required this.auction,
    required this.onEdit,
    required this.onDelete,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final euro = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
    final fmt  = DateFormat('dd MMM, HH:mm', 'nl_NL');

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          // Thumbnail
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        const Color(0xFFF0F0F5),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: auction.thumbnailUrl.isNotEmpty
                ? Image.network(auction.thumbnailUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_outlined, color: Color(0xFFB0B8C8)))
                : Center(child: Text(auction.category.emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 8),

          // Title + location
          Expanded(flex: 4, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(auction.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
                  color: Color(0xFF1A1D27)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              if (auction.location != null)
                Text(auction.location!,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6))),
            ],
          )),

          // Category
          Expanded(flex: 2, child: Text(
            '${auction.category.emoji} ${auction.category.label}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5A6478)),
          )),

          // Status badge
          Expanded(flex: 1, child: _StatusBadge(auction.status)),

          // Current bid
          Expanded(flex: 1, child: Text(
            euro.format(auction.currentBid),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
              color: Color(0xFF1A1D27)),
          )),

          // Bid count
          Expanded(flex: 1, child: Row(children: [
            const Icon(Icons.gavel, size: 12, color: Color(0xFF8B9CB6)),
            const SizedBox(width: 4),
            Text('${auction.bidCount}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5A6478))),
          ])),

          // End date
          Expanded(flex: 2, child: Text(
            fmt.format(auction.endsAt),
            style: const TextStyle(fontSize: 11, color: Color(0xFF5A6478)),
          )),

          // Actions
          SizedBox(width: 100, child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionMenu(auction: auction, onEdit: onEdit, onDelete: onDelete, onStatus: onStatus),
            ],
          )),
        ]),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final AdminAuctionEntity   auction;
  final VoidCallback         onEdit;
  final VoidCallback         onDelete;
  final ValueChanged<AuctionStatus> onStatus;

  const _ActionMenu({
    required this.auction, required this.onEdit,
    required this.onDelete, required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 18, color: Color(0xFF8B9CB6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      itemBuilder: (_) => [
        _menuItem('edit',   Icons.edit_outlined,         'Bewerken'),
        if (auction.status == AuctionStatus.draft)
          _menuItem('publish', Icons.rocket_launch_outlined, 'Publiceren als Live'),
        if (auction.status == AuctionStatus.draft)
          _menuItem('schedule', Icons.schedule_outlined,    'Plannen'),
        if (auction.status == AuctionStatus.live)
          _menuItem('end',   Icons.stop_circle_outlined,   'Beëindigen'),
        if (auction.status != AuctionStatus.cancelled)
          _menuItem('cancel', Icons.cancel_outlined,        'Annuleren'),
        const PopupMenuDivider(),
        _menuItem('delete', Icons.delete_outline, 'Verwijderen', red: true),
      ],
      onSelected: (val) {
        switch (val) {
          case 'edit':     onEdit(); break;
          case 'publish':  onStatus(AuctionStatus.live); break;
          case 'schedule': onStatus(AuctionStatus.scheduled); break;
          case 'end':      onStatus(AuctionStatus.ended); break;
          case 'cancel':   onStatus(AuctionStatus.cancelled); break;
          case 'delete':   onDelete(); break;
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(
      String val, IconData icon, String label, {bool red = false}) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(icon, size: 15, color: red ? Colors.red : const Color(0xFF5A6478)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
          fontSize: 13, color: red ? Colors.red : const Color(0xFF1A1D27))),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AuctionStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final Map<AuctionStatus, (Color, Color)> colors = {
      AuctionStatus.live:       (Colors.green.shade50,    Colors.green.shade700),
      AuctionStatus.scheduled:  (Colors.blue.shade50,     Colors.blue.shade700),
      AuctionStatus.draft:      (const Color(0xFFF0F0F5), const Color(0xFF5A6478)),
      AuctionStatus.ended:      (Colors.grey.shade100,    Colors.grey.shade600),
      AuctionStatus.cancelled:  (Colors.red.shade50,      Colors.red.shade600),
    };
    final (bg, fg) = colors[status] ?? (Colors.grey.shade100, Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (status == AuctionStatus.live)
          Container(
            width: 5, height: 5, margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
        Text(status.label, style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
      ]),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: Color(0xFF8B9CB6), letterSpacing: 0.5));
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 4,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.gavel_rounded, size: 56, color: Color(0xFFCBD5E1)),
        const SizedBox(height: 12),
        const Text('Geen veilingen gevonden',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 4),
        const Text('Pas filters aan of maak een nieuwe veiling aan',
          style: TextStyle(color: Color(0xFF8B9CB6), fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nieuwe veiling'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }
}
