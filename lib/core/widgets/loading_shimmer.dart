import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

// ── Base shimmer box ─────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppDimensions.radiusS,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      baseColor      ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ── Auction card shimmer ─────────────────────────────────────────────────────

class AuctionCardShimmer extends StatelessWidget {
  const AuctionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: AppDimensions.auctionImageHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.cardRadius),
                ),
              ),
            ),
            // Info placeholders
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(double.infinity, 13),
                  const SizedBox(height: 6),
                  _bar(120, 11),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _bar(70, 16),
                      _bar(60, 11),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, double height) => Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

// ── Auction grid shimmer (6 placeholder cards) ───────────────────────────────

class AuctionGridShimmer extends StatelessWidget {
  final int count;
  const AuctionGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.gridPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:    AppDimensions.gridCrossAxisCount,
        childAspectRatio:  AppDimensions.gridChildAspectRatio,
        crossAxisSpacing:  AppDimensions.gridSpacing,
        mainAxisSpacing:   AppDimensions.gridSpacing,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const AuctionCardShimmer(),
    );
  }
}

// ── Auction detail shimmer ───────────────────────────────────────────────────

class AuctionDetailShimmer extends StatelessWidget {
  const AuctionDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(height: AppDimensions.detailImageHeight, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pill(80, 28),
                  const SizedBox(height: 12),
                  _bar(double.infinity, 24),
                  const SizedBox(height: 8),
                  _bar(200, 24),
                  const SizedBox(height: 8),
                  _bar(120, 16),
                  const SizedBox(height: 24),
                  // Bid box
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.bidBoxRadius),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_bar(80, 40), _bar(80, 40), _bar(80, 40)],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double width, double height) => Container(
        width:  width,
        height: height,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  Widget _pill(double width, double height) => Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
      );
}

// ── My-auctions list shimmer ─────────────────────────────────────────────────

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Leading image
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            const SizedBox(width: 12),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 160, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 100, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int count;
  const ListShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const ListTileShimmer(),
    );
  }
}

// ── Profile shimmer ──────────────────────────────────────────────────────────

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor:      Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header
          Container(height: 200, color: Colors.white),
          const SizedBox(height: 16),
          // Settings rows
          for (int i = 0; i < 6; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Generic full-screen loading overlay ─────────────────────────────────────

class FullScreenLoader extends StatelessWidget {
  final String? message;
  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryRed, strokeWidth: 3),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(message!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Inline loading indicator ─────────────────────────────────────────────────

class InlineLoader extends StatelessWidget {
  final double size;
  final Color? color;
  const InlineLoader({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? AppColors.primaryRed,
      ),
    );
  }
}
