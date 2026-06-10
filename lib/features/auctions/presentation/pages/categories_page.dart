// lib/features/auctions/presentation/pages/categories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/auction_entity.dart';

/// /categorieen — a grid of all auction categories. Tapping one opens the
/// all-auctions browse page pre-filtered to that category.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const _icons = <AuctionCategory, IconData>{
    AuctionCategory.vacation: Icons.beach_access_rounded,
    AuctionCategory.beauty: Icons.spa_rounded,
    AuctionCategory.sauna: Icons.hot_tub_rounded,
    AuctionCategory.food: Icons.restaurant_rounded,
    AuctionCategory.products: Icons.shopping_bag_rounded,
    AuctionCategory.experiences: Icons.celebration_rounded,
    AuctionCategory.sports: Icons.sports_soccer_rounded,
    AuctionCategory.wellness: Icons.self_improvement_rounded,
    AuctionCategory.dayTrips: Icons.directions_bus_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.navCategories(context),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          children: [
            // Prominent "all auctions" entry.
            _AllAuctionsTile(),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              AppStrings.navCategories(context),
              style: TextStyle(
                fontSize: AppDimensions.fontXL,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimensions.spaceM,
              crossAxisSpacing: AppDimensions.spaceM,
              childAspectRatio: 1.5,
              children: [
                for (final cat in AuctionCategory.values)
                  _CategoryTile(
                    label: cat.label,
                    icon: _icons[cat] ?? Icons.category_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.allAuctions, extra: cat);
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

class _AllAuctionsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.allAuctions),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          gradient: AppColors.luxuryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppColors.goldGlow(opacity: 0.25),
        ),
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded,
                color: AppColors.textOnGold, size: AppDimensions.iconL),
            const SizedBox(width: AppDimensions.spaceL),
            Expanded(
              child: Text(
                AppStrings.allAuctions(context),
                style: const TextStyle(
                  color: AppColors.textOnGold,
                  fontWeight: FontWeight.w800,
                  fontSize: AppDimensions.fontTitle,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textOnGold),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryTile(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassFill : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : AppColors.ivoryBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Icon(icon, color: AppColors.gold, size: AppDimensions.iconM),
            ),
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontBody,
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
