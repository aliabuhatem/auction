import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  static const _paths = [
    AppRoutes.home,
    AppRoutes.myAuctions,
    AppRoutes.scratchCard,
    AppRoutes.tickets,
    AppRoutes.profile,
  ];

  static const _icons = [
    (Icons.home_outlined,           Icons.home_rounded),
    (Icons.gavel_outlined,          Icons.gavel_rounded),
    (Icons.style_outlined,          Icons.style_rounded),
    (Icons.local_activity_outlined, Icons.local_activity),
    (Icons.person_outline_rounded,  Icons.person_rounded),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _paths.length; i++) {
      if (location.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  List<String> _labels(BuildContext context) => [
    AppStrings.navHome(context),
    AppStrings.navAuctions(context),
    AppStrings.navScratchCard(context),
    AppStrings.navVouchers(context),
    AppStrings.navProfile(context),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = _labels(context);

    final tabs = List.generate(_paths.length, (i) => _TabItem(
      icon:       _icons[i].$1,
      activeIcon: _icons[i].$2,
      label:      labels[i],
      path:       _paths[i],
    ));

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: currentIndex,
        isDark: isDark,
        onTap: (i) => context.go(_paths[i]),
        tabs: tabs,
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  final List<_TabItem> tabs;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bg.withValues(alpha: isDark ? 0.85 : 0.95),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  return Expanded(
                    child: _NavItem(
                      tab: tabs[i],
                      isSelected: currentIndex == i,
                      isDark: isDark,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final _TabItem tab;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final iconColor = selected
        ? AppColors.primaryRed
        : (widget.isDark ? const Color(0xFF4A5568) : AppColors.navUnselected);
    final labelColor = selected
        ? AppColors.primaryRed
        : (widget.isDark ? const Color(0xFF4A5568) : AppColors.navUnselected);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryRed.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? widget.tab.activeIcon : widget.tab.icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize:   10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:      labelColor,
              ),
              child: Text(widget.tab.label),
            ),
          ],
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
