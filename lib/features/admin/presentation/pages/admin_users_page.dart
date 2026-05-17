import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_users_bloc.dart';
import '../widgets/admin_shell.dart';
import '../widgets/admin_stat_card.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../data/datasources/admin_users_datasource.dart';
import '../../../../core/constants/app_colors.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          AdminUsersBloc(ctx.read<AdminUsersDatasource>())
            ..add(const LoadAdminUsers()),
      child: const AdminShell(selectedIndex: 3, child: _UsersBody()),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminUsersBloc, AdminUsersState>(
      listenWhen: (_, s) => s is AdminUsersError,
      listener: (context, state) {
        if (state is AdminUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is AdminUsersInitial || state is AdminUsersLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed));
        }
        if (state is AdminUsersError) {
          return Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(state.message,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<AdminUsersBloc>().add(const LoadAdminUsers()),
                child: const Text('Opnieuw proberen'),
              ),
            ]),
          );
        }
        if (state is AdminUsersLoaded) return _UsersContent(state: state);
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _UsersContent extends StatelessWidget {
  final AdminUsersLoaded state;
  const _UsersContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gebruikers',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color(0xFF1A1D27))),
              SizedBox(height: 2),
              Text('Overzicht van alle geregistreerde gebruikers',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
            ]),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<AdminUsersBloc>().add(const LoadAdminUsers()),
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Vernieuwen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A6478),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              label:    'Totaal gebruikers',
              value:    '${state.stats.totalUsers}',
              icon:     Icons.people_rounded,
              color:    const Color(0xFF3B82F6),
              subtitle: 'Geregistreerd',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'Nieuw vandaag',
              value:    '${state.stats.newToday}',
              icon:     Icons.person_add_rounded,
              color:    const Color(0xFF10B981),
              subtitle: 'Nieuwe registraties',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'Nieuw deze week',
              value:    '${state.stats.newThisWeek}',
              icon:     Icons.trending_up_rounded,
              color:    const Color(0xFFF59E0B),
              subtitle: 'Afgelopen 7 dagen',
            )),
            const SizedBox(width: 16),
            Expanded(
                child: AdminStatCard(
              label:    'In lijst',
              value:    '${state.users.length}',
              icon:     Icons.format_list_bulleted_rounded,
              color:    AppColors.primaryRed,
              subtitle: state.search.isNotEmpty ? 'Gefilterd' : 'Weergegeven',
            )),
          ]),
          const SizedBox(height: 24),

          // Filter bar
          _FilterBar(
              currentSearch: state.search,
              currentActive: state.isActiveFilter),
          const SizedBox(height: 16),

          // Table + detail panel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _UsersTable(users: state.users)),
              if (state.selectedUser != null) ...[
                const SizedBox(width: 16),
                SizedBox(
                    width: 320,
                    child: _UserDetailPanel(user: state.selectedUser!)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatefulWidget {
  final String  currentSearch;
  final bool?   currentActive;
  const _FilterBar({this.currentSearch = '', this.currentActive});

  @override
  State<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<_FilterBar> {
  late final TextEditingController _search;
  bool? _active;

  static const _opts = [
    (null,  'Alle'),
    (true,  'Actief'),
    (false, 'Inactief'),
  ];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.currentSearch);
    _active = widget.currentActive;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _apply() => context.read<AdminUsersBloc>().add(FilterAdminUsers(
        search:   _search.text,
        isActive: _active,
      ));

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (v, label) in _opts)
          FilterChip(
            label: Text(label),
            selected: _active == v,
            onSelected: (_) {
              setState(() => _active = v);
              _apply();
            },
            selectedColor: AppColors.primaryRed.withValues(alpha: 0.12),
            checkmarkColor: AppColors.primaryRed,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _active == v ? FontWeight.w700 : FontWeight.w500,
              color: _active == v
                  ? AppColors.primaryRed
                  : const Color(0xFF5A6478),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(
              color: _active == v
                  ? AppColors.primaryRed.withValues(alpha: 0.3)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        SizedBox(
          width: 240,
          child: TextField(
            controller: _search,
            onChanged: (_) => _apply(),
            decoration: InputDecoration(
              hintText: 'Zoek op naam of e-mail…',
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

// ── Users table ───────────────────────────────────────────────────────────────

class _UsersTable extends StatelessWidget {
  final List<AppUserEntity> users;
  const _UsersTable({required this.users});

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
            child: Text('${users.length} gebruiker${users.length != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1D27))),
          ),
          const SizedBox(height: 8),
          Container(
            color: const Color(0xFFFAFAFC),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(children: [
              SizedBox(width: 40),
              SizedBox(width: 12),
              Expanded(flex: 3, child: _TH('Naam')),
              Expanded(flex: 3, child: _TH('E-mail')),
              SizedBox(width: 100, child: _TH('Telefoon')),
              SizedBox(width: 100, child: _TH('Lid sinds')),
              SizedBox(width: 88, child: _TH('Status')),
              SizedBox(width: 36),
            ]),
          ),
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Geen gebruikers gevonden.',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            ...users.map((u) => _UserRow(user: u)),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AppUserEntity user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<AdminUsersBloc, bool>((b) {
      final s = b.state;
      return s is AdminUsersLoaded && s.selectedUser?.id == user.id;
    });
    final dtFmt = DateFormat('dd/MM/yy');

    return InkWell(
      onTap: () => context.read<AdminUsersBloc>().add(
            SelectAdminAppUser(isSelected ? null : user),
          ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.04)
              : Colors.transparent,
          border: const Border(top: BorderSide(color: Color(0xFFF8F8FA))),
        ),
        child: Row(children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.12),
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(user.initials,
                    style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 12))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
              flex: 3,
              child: Text(user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D27)))),
          Expanded(
              flex: 3,
              child: Text(user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A6478)))),
          SizedBox(
              width: 100,
              child: Text(user.phoneNumber ?? '—',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A6478)))),
          SizedBox(
              width: 100,
              child: Text(dtFmt.format(user.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A6478)))),
          SizedBox(
            width: 88,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (user.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (user.isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280))
                      .withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                user.isActive ? 'Actief' : 'Inactief',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: user.isActive
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280)),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 18, color: Color(0xFF8B9CB6)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                    user.isActive ? 'Deactiveer' : 'Activeer',
                    style: TextStyle(
                        color: user.isActive ? Colors.red : Colors.green,
                        fontSize: 13),
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'toggle') {
                  context
                      .read<AdminUsersBloc>()
                      .add(ToggleAppUserActive(user.id, !user.isActive));
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── User detail panel ─────────────────────────────────────────────────────────

class _UserDetailPanel extends StatelessWidget {
  final AppUserEntity user;
  const _UserDetailPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    final dtFmt = DateFormat('dd MMM yyyy', 'nl_NL');
    final bloc  = context.read<AdminUsersBloc>();

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
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(children: [
              const Expanded(
                  child: Text('Gebruiker details',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1D27)))),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF8B9CB6)),
                onPressed: () =>
                    bloc.add(const SelectAdminAppUser(null)),
              ),
            ]),
          ),
          const Divider(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Avatar + name
                Center(
                  child: Column(children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          AppColors.primaryRed.withValues(alpha: 0.12),
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(user.initials,
                              style: const TextStyle(
                                  color: AppColors.primaryRed,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22))
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(user.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Color(0xFF1A1D27))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: (user.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280))
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.isActive ? 'Actief' : 'Inactief',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: user.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF6B7280)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF0F0F5)),
                const SizedBox(height: 12),

                _Row('E-mail', user.email),
                if (user.phoneNumber != null)
                  _Row('Telefoon', user.phoneNumber!),
                _Row('Lid sinds', dtFmt.format(user.createdAt)),
                _Row('User-ID', user.id, mono: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(
                  user.isActive
                      ? Icons.block_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 15,
                ),
                label: Text(user.isActive ? 'Deactiveer account' : 'Activeer account'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      user.isActive ? Colors.red : const Color(0xFF10B981),
                  side: BorderSide(
                      color: user.isActive
                          ? Colors.red
                          : const Color(0xFF10B981)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  bloc.add(ToggleAppUserActive(user.id, !user.isActive));
                  bloc.add(const SelectAdminAppUser(null));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final String label, value;
  final bool   mono;
  const _Row(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 76,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF8B9CB6)))),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: mono ? 'monospace' : null,
                      color: const Color(0xFF1A1D27)))),
        ]),
      );
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
