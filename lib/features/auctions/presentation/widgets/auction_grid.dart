import 'package:flutter/material.dart';
import '../../domain/entities/auction_entity.dart';
import '../../../../core/widgets/auction_card.dart';
import '../../../../core/constants/app_dimensions.dart';

class AuctionGrid extends StatelessWidget {
  final List<AuctionEntity> auctions;
  final bool hasMore;
  final bool isLoadingMore;
  const AuctionGrid({super.key, required this.auctions, this.hasMore = false, this.isLoadingMore = false});

  @override
  Widget build(BuildContext context) {
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppDimensions.gridCrossAxisCount,
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
