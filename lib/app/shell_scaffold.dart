import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

/// Bottom-nav shell — 5 tabs matching the live site:
/// Home · Categorie · Zoeken (center, elevated) · Recent · Menu.
/// Backed by a [StatefulNavigationShell] so each tab keeps its own state.
class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellScaffold({super.key, required this.navigationShell});

  // Tab 2 (Zoeken) is the elevated centre button.
  static const _searchIndex = 2;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops to its root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _ShellBottomNav(
        currentIndex: navigationShell.currentIndex,
        isDark: isDark,
        onTap: _goBranch,
        labels: [
          AppStrings.navHome(context),
          AppStrings.navCategories(context),
          AppStrings.navSearch(context),
          AppStrings.navRecent(context),
          AppStrings.navMenu(context),
        ],
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  final List<String> labels;

  const _ShellBottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    required this.labels,
  });

  static const _icons = <(IconData, IconData)>[
    (Icons.home_outlined, Icons.home_rounded),
    (Icons.grid_view_outlined, Icons.grid_view_rounded),
    (Icons.search_rounded, Icons.search_rounded), // centre — handled separately
    (Icons.history_outlined, Icons.history_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkSurface : AppColors.ivorySurface;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: bg.withValues(alpha: isDark ? 0.75 : 0.95),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.goldBorder
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(5, (i) {
                  if (i == ShellScaffold._searchIndex) {
                    return Expanded(
                      child: _CenterSearchButton(
                        selected: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    );
                  }
                  return Expanded(
                    child: _NavItem(
                      icon: _icons[i].$1,
                      activeIcon: _icons[i].$2,
                      label: labels[i],
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

class _CenterSearchButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _CenterSearchButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            shape: BoxShape.circle,
            boxShadow: AppColors.goldGlow(opacity: selected ? 0.55 : 0.35),
            border: Border.all(
              color: AppColors.textOnGold.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: const Icon(Icons.search_rounded,
              color: AppColors.textOnGold, size: 26),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
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
    final color = selected
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.25),
                            blurRadius: 12)
                      ]
                    : null,
              ),
              child: Icon(selected ? widget.activeIcon : widget.icon,
                  color: color, size: 23),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
                color: color,
              ),
              child: Text(widget.label),
            ),
          ],
        ),
      ),
    );
  }
}
