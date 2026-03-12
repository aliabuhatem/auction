import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';
import '../core/constants/app_colors.dart';

/// Bottom navigation shell that wraps all tab pages.
class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined,        activeIcon: Icons.home,           label: 'Home',          path: AppRoutes.home),
    _TabItem(icon: Icons.gavel_outlined,       activeIcon: Icons.gavel,          label: 'Mijn veilingen',path: AppRoutes.myAuctions),
    _TabItem(icon: Icons.style_outlined,       activeIcon: Icons.style,          label: 'Kraskaart',     path: AppRoutes.scratchCard),
    _TabItem(icon: Icons.local_activity_outlined, activeIcon: Icons.local_activity, label: 'Vouchers',   path: AppRoutes.tickets),
    _TabItem(icon: Icons.person_outlined,      activeIcon: Icons.person,         label: 'Profiel',       path: AppRoutes.profile),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset:     const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          elevation:    0,
          backgroundColor: Colors.white,
          selectedItemColor:   AppColors.primaryRed,
          unselectedItemColor: AppColors.navUnselected,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => context.go(_tabs[index].path),
          items: _tabs
              .asMap()
              .entries
              .map((e) => BottomNavigationBarItem(
                    icon:       Icon(e.value.icon),
                    activeIcon: Icon(e.value.activeIcon),
                    label:      e.value.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  final String   path;
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
