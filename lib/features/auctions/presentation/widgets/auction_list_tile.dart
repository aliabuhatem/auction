// lib/features/auctions/presentation/widgets/auction_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/countdown_widget.dart';
import '../../../../core/widgets/product_image.dart';
import '../../domain/entities/auction_entity.dart';

/// Compact single-row presentation of an auction, used by the "Lijst" view of
/// the all-auctions page. Image left, details right.
class AuctionListTile extends StatelessWidget {
  final AuctionEntity auction;
  const AuctionListTile({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? const Color(0xFF8892A4) : AppColors.textSecondary;
    final remaining = auction.endsAt.difference(DateTime.now());
    final isUrgent = remaining.inMinutes < 10;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(AppRoutes.auctionDetailPath(auction.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassFill : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : AppColors.ivoryBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imageUrl: auction.imageUrl,
                    seed: auction.id,
                    fit: BoxFit.cover,
                  ),
                  if (auction.savingsPercent > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${auction.savingsPercent.round()}%',
                          style: const TextStyle(
                            color: AppColors.textOnGold,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auction.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppDimensions.fontBody,
                        height: 1.3,
                        color: textPrimary,
                      ),
                    ),
                    if (auction.location.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              auction.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: AppDimensions.fontXS,
                                  color: textSecondary),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.currentBid(context).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(auction.currentBid),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: AppDimensions.fontXL,
                                  color: AppColors.accentBright,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUrgent
                                      ? Icons.local_fire_department_rounded
                                      : Icons.timer_outlined,
                                  size: 12,
                                  color: isUrgent
                                      ? AppColors.error
                                      : textSecondary,
                                ),
                                const SizedBox(width: 3),
                                CountdownWidget(
                                  endsAt: auction.endsAt,
                                  style: TextStyle(
                                    fontSize: AppDimensions.fontS,
                                    fontWeight: FontWeight.w700,
                                    color: isUrgent
                                        ? AppColors.error
                                        : textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${auction.bidCount}× ${AppStrings.bids}',
                              style: TextStyle(
                                fontSize: AppDimensions.fontXS,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
