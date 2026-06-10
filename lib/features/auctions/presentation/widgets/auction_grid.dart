import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/auction_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive.dart';

class AuctionGrid extends StatelessWidget {
  final List<AuctionEntity> auctions;
  final bool hasMore;
  final bool isLoadingMore;
  const AuctionGrid({super.key, required this.auctions, this.hasMore = false, this.isLoadingMore = false});

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty && !isLoadingMore) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassFill : AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: isDark ? AppColors.glassBorder : AppColors.ivoryBorder),
                ),
                child: const Icon(Icons.gavel_outlined,
                    size: 38, color: AppColors.textHint),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: -5, end: 5, duration: 2200.ms, curve: Curves.easeInOut),
              const SizedBox(height: 18),
              Text(
                AppStrings.noAuctions(context),
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == auctions.length) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ));
            }
            return AuctionCard(auction: auctions[index]);
          },
          childCount: (hasMore && isLoadingMore) ? auctions.length + 1 : auctions.length,
        ),
        // Adaptive columns: derive the count from available width so the grid
        // shows 2 cards on a phone and 3+ on tablets/foldables/large windows
        // without stretching cards unnaturally wide. (flutter-build-responsive-layout)
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: Breakpoints.auctionCardMaxExtent,
          childAspectRatio: AppDimensions.gridChildAspectRatio,
          crossAxisSpacing: AppDimensions.gridSpacing,
          mainAxisSpacing: AppDimensions.gridSpacing,
        ),
      ),
    );
  }
}

class AuctionHorizontalList extends StatelessWidget {
  final List<AuctionEntity> auctions;
  const AuctionHorizontalList({super.key, required this.auctions});

  @override
  Widget build(BuildContext context) {
    if (auctions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 160,
          child: AuctionCard(auction: auctions[i]),
        ),
      ),
    );
  }
}
