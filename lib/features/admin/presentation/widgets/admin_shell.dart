import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_auth_bloc.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class AdminShell extends StatefulWidget {
  final Widget child;
  final int    selectedIndex;
  const AdminShell({super.key, required this.child, required this.selectedIndex});
  @override State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {

  static const _navItems = [
    _NavItem(label: 'Dashboard',    icon: Icons.dashboard_outlined,        activeIcon: Icons.dashboard,         route: AppRoutes.adminDashboard),
    _NavItem(label: 'Veilingen',    icon: Icons.gavel_outlined,            activeIcon: Icons.gavel,             route: AppRoutes.adminAuctions),
    _NavItem(label: 'Producten',    icon: Icons.inventory_2_outlined,      activeIcon: Icons.inventory_2,       route: AppRoutes.adminProducts),
    _NavItem(label: 'Gebruikers',   icon: Icons.people_outline,            activeIcon: Icons.people,            route: AppRoutes.adminUsers,    permission: 'users'),
    _NavItem(label: 'Biedingen',    icon: Icons.trending_up_outlined,      activeIcon: Icons.trending_up,       route: AppRoutes.adminBids),
    _NavItem(label: 'Betalingen',   icon: Icons.credit_card_outlined,      activeIcon: Icons.credit_card,       route: AppRoutes.adminOrders),
    _NavItem(label: 'Vouchers',     icon: Icons.local_activity_outlined,   activeIcon: Icons.local_activity,    route: AppRoutes.adminVouchers),
    _NavItem(label: 'Meldingen',    icon: Icons.notifications_outlined,    activeIcon: Icons.notifications,     route: AppRoutes.adminNotifications),
    _NavItem(label: 'Instellingen', icon: Icons.settings_outlined,         activeIcon: Icons.settings,          route: AppRoutes.adminSettings, permission: 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.select<AdminAuthBloc, AdminUserEntity?>((bloc) {
      final s = bloc.state;
      return s is AdminAuthenticated ? s.user : null;
    });

    // Override the app-level button theme (minimumSize: double.infinity) which
    // crashes inside Row's unbounded first-pass layout on web.
    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(minimumSize: const Size(0, 36)),
        ),
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────────
          _Sidebar(
            user:          user,
            items:         _navItems,
            selectedIndex: widget.selectedIndex,
            onSelect: (route) => context.go(route),
            onLogout: () {
              context.read<AdminAuthBloc>().add(AdminLogoutRequested());
              context.go(AppRoutes.adminLogin);
            },
          ),
          // ── Main content ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(user: user),
                // Cap the content column on ultra-wide monitors so tables and
                // forms stay readable instead of stretching edge to edge.
                // (flutter-build-responsive-layout)
                Expanded(
                  child: MaxWidthContent(
                    maxWidth: Breakpoints.dashboardContent,
                    alignment: Alignment.topLeft,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),   // Theme
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final AdminUserEntity?  user;
  final List<_NavItem>    items;
  final int               selectedIndex;
  final void Function(String) onSelect;
  final VoidCallback          onLogout;

  const _Sidebar({
    required this.user,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  bool _canSee(_NavItem item) {
    if (item.permission == 'users'    && user?.canManageUsers != true)    return false;
    if (item.permission == 'settings' && user?.canManageSettings != true) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color:  Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFF0F0F5))),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF0F0F5))),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color:        AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vakantieveilingen',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1A1D27))),
                  Text('Admin Panel',
                    style: TextStyle(fontSize: 10, color: Color(0xFF8B9CB6))),
                ],
              ),
            ]),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ...items.asMap().entries.map((entry) {
                  final i    = entry.key;
                  final item = entry.value;
                  if (!_canSee(item)) return const SizedBox.shrink();
                  final active = i == selectedIndex;
                  return _SidebarTile(
                    item:   item,
                    active: active,
                    onTap:  () => onSelect(item.route),
                  );
                }),
              ],
            ),
          ),

          // User profile & logout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF0F0F5))),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryRed.withValues(alpha:0.12),
                      child: Text(user?.initials ?? '?',
                        style: const TextStyle(
                          color:      AppColors.primaryRed,
                          fontWeight: FontWeight.w800,
                          fontSize:   12,
                        )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12,
                            color: Color(0xFF1A1D27)), overflow: TextOverflow.ellipsis),
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color:        AppColors.primaryRed.withValues(alpha:0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(user?.role.label ?? '',
                            style: const TextStyle(color: AppColors.primaryRed, fontSize: 9,
                              fontWeight: FontWeight.w700)),
                        ),
                      ],
                    )),
                  ]),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap:        onLogout,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: const Row(children: [
                      Icon(Icons.logout_rounded, size: 15, color: Color(0xFFE53935)),
                      SizedBox(width: 8),
                      Text('Uitloggen', style: TextStyle(
                        color: Color(0xFFE53935), fontWeight: FontWeight.w600, fontSize: 12)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final _NavItem item;
  final bool     active;
  final VoidCallback onTap;
  const _SidebarTile({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color:        active ? AppColors.primaryRed.withValues(alpha:0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap:        onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size:  18,
                color: active ? AppColors.primaryRed : const Color(0xFF8B9CB6),
              ),
              const SizedBox(width: 10),
              Text(item.label, style: TextStyle(
                color:      active ? AppColors.primaryRed : const Color(0xFF5A6478),
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize:   13,
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AdminUserEntity? user;
  const _TopBar({this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Goedemorgen' : hour < 18 ? 'Goedemiddag' : 'Goedenavond';
    final now = DateTime.now();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color:  Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F5))),
      ),
      child: Row(
        children: [
          // Flexible so a long admin name can't overflow the top bar.
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, ${user?.displayName.split(' ').first ?? ''} 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                    color: Color(0xFF1A1D27))),
                Text(
                  '${_weekday(now.weekday)} ${now.day} ${_month(now.month)} ${now.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6)),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:        Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border:       Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Container(width: 6, height: 6,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Live', style: TextStyle(
                color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF5A6478)),
            onPressed: () => context.go(AppRoutes.adminNotifications),
          ),
        ],
      ),
    );
  }

  String _weekday(int d) => ['Ma','Di','Wo','Do','Vr','Za','Zo'][d - 1];
  String _month(int m)   => ['jan','feb','mrt','apr','mei','jun',
                              'jul','aug','sep','okt','nov','dec'][m - 1];
}

// ── Model ────────────────────────────────────────────────────────────────────

class _NavItem {
  final String    label;
  final IconData  icon;
  final IconData  activeIcon;
  final String    route;
  final String?   permission;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.permission,
  });
}
