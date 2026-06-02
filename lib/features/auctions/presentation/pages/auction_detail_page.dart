import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/bidding_bloc.dart';
import '../../domain/entities/auction_entity.dart';
import '../widgets/bid_history_list.dart';
import '../../../../core/widgets/bid_button.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/countdown_widget.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});
  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<BiddingBloc>().add(LoadAuctionForBidding(widget.auctionId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BiddingBloc, BiddingState>(
      listener: (context, state) {
        if (state is BiddingSuccess) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(AppStrings.bidPlaced(context),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        } else if (state is BiddingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error), // error comes from server, not i18n
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        } else if (state is BiddingLoaded && state.wasOutbid) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.outbid(context)),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        }
      },
      builder: (context, state) {
        if (state is BiddingLoading) {
          return Scaffold(appBar: AppBar(), body: const AuctionDetailShimmer());
        }
        if (state is BiddingError) {
          return Scaffold(
            body: Center(child: Text(state.message,
                style: const TextStyle(color: AppColors.textSecondary))),
          );
        }

        final auction = switch (state) {
          BiddingLoaded(:final auction)  => auction,
          BiddingPlacing(:final auction) => auction,
          BiddingSuccess(:final auction) => auction,
          BiddingFailed(:final auction)  => auction,
          _ => null,
        };
        if (auction == null) return const Scaffold(body: AuctionDetailShimmer());

        final isPlacing = state is BiddingPlacing;
        final isDark    = Theme.of(context).brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              slivers: [
                // ── Immersive image app bar ───────────────────────────────
                SliverAppBar(
                  expandedHeight:  320,
                  pinned:          true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _ImageGallery(
                      imageUrls:    auction.imageUrls,
                      imageIndex:   _imageIndex,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                    ),
                  ),
                  leading: _GlassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    _GlassIconButton(
                      icon: auction.isWatchlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: auction.isWatchlisted
                          ? AppColors.primaryRed
                          : Colors.white,
                      onTap: () => context.read<BiddingBloc>()
                          .add(ToggleWatchlist(auction.id)),
                    ),
                    const SizedBox(width: 4),
                    _GlassIconButton(
                      icon: Icons.share_rounded,
                      onTap: () =>
                          Share.share('Check deze veiling: ${auction.title}'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // ── Body content ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(auction: auction, isDark: isDark),
                      _BidPanel(
                        auction: auction, isPlacing: isPlacing, isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _StatsRow(auction: auction, isDark: isDark),
                      const SizedBox(height: 20),
                      _TabSection(
                        auction:       auction,
                        tabController: _tabController,
                        isDark:        isDark,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15), width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Image gallery ─────────────────────────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int imageIndex;
  final ValueChanged<int> onPageChanged;
  const _ImageGallery({
    required this.imageUrls,
    required this.imageIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return Container(color: AppColors.backgroundGrey);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: onPageChanged,
          itemBuilder: (_, i) => Image.network(
            imageUrls[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.backgroundGrey,
              child: const Center(child: Icon(Icons.image_not_supported_outlined,
                  size: 48, color: AppColors.textHint)),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                color: AppColors.backgroundGrey,
                child: Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                        : null,
                    color: AppColors.primaryRed, strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),

        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.imageOverlay),
          ),
        ),

        if (imageUrls.length > 1)
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width:  i == imageIndex ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == imageIndex
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final AuctionEntity auction;
  final bool isDark;
  const _HeaderSection({required this.auction, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary   = isDark ? AppColors.textOnDark   : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF8892A4) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        AppColors.primaryRed.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              auction.category.label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w700,
                fontSize: 11, letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            auction.title,
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800,
              color: textPrimary, letterSpacing: -0.3, height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: textSecondary),
              const SizedBox(width: 4),
              Text(auction.location,
                  style: TextStyle(color: textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Bid panel ─────────────────────────────────────────────────────────────────

class _BidPanel extends StatelessWidget {
  final AuctionEntity auction;
  final bool isPlacing;
  final bool isDark;
  const _BidPanel({required this.auction, required this.isPlacing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:        isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: isDark ? 1 : 1.5,
          ),
          boxShadow: isDark
              ? null
              : [const BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.currentBid(context),
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(auction.currentBid),
                        style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w900,
                          color: AppColors.primaryRed, letterSpacing: -0.5, height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${auction.bidCount} ${AppStrings.tabBids(context).toLowerCase()}',
                          style: const TextStyle(color: AppColors.textSecondary,
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppStrings.endsIn(context),
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    _TimerChip(endsAt: auction.endsAt),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            BidButton(
              nextBid:   auction.currentBid + 1.0,
              isLoading: isPlacing,
              onTap: isPlacing
                  ? null
                  : () => context.read<BiddingBloc>().add(SubmitBid(
                        auctionId: auction.id,
                        amount:    auction.currentBid + 1.0,
                      )),
            ),
            const SizedBox(height: 10),
            AlarmButton(
              isSet: false,
              onTap: () => context.read<BiddingBloc>().add(SetAlarm(auction.id)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final DateTime endsAt;
  const _TimerChip({required this.endsAt});

  @override
  Widget build(BuildContext context) {
    final remaining = endsAt.difference(DateTime.now());
    final isUrgent  = remaining.inMinutes < 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.primaryRed.withValues(alpha: 0.10)
            : AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CountdownWidget(
        endsAt: endsAt,
        style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5,
          color: isUrgent ? AppColors.primaryRed : AppColors.success,
        ),
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final AuctionEntity auction;
  final bool isDark;
  const _StatsRow({required this.auction, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(label: AppStrings.retailValue(context),
              value: CurrencyFormatter.format(auction.retailValue),
              color: AppColors.textSecondary, isDark: isDark),
          const SizedBox(width: 10),
          _StatCard(label: AppStrings.yourSaving(context),
              value: '-${auction.savingsPercent.toStringAsFixed(0)}%',
              color: AppColors.success, isDark: isDark),
          const SizedBox(width: 10),
          _StatCard(label: AppStrings.tabBids(context),
              value: '${auction.bidCount}',
              color: AppColors.primaryRed, isDark: isDark),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;
  final bool   isDark;
  const _StatCard({
    required this.label, required this.value,
    required this.color, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color:        isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:       isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isDark
              ? null
              : [const BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

// ── Tab section ───────────────────────────────────────────────────────────────

class _TabSection extends StatelessWidget {
  final AuctionEntity auction;
  final TabController tabController;
  final bool isDark;
  const _TabSection({
    required this.auction, required this.tabController, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            decoration: BoxDecoration(
              color:        isDark ? AppColors.darkCard : AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller:    tabController,
              dividerColor:  Colors.transparent,
              indicator: BoxDecoration(
                gradient:     AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(
                  color: AppColors.primaryShadow, blurRadius: 8, offset: Offset(0, 2),
                )],
              ),
              indicatorSize:       TabBarIndicatorSize.tab,
              labelColor:          Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [Tab(text: AppStrings.tabDescription(context)), Tab(text: AppStrings.tabBids(context))],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: tabController,
              children: [
                SingleChildScrollView(
                  child: Text(
                    auction.description,
                    style: TextStyle(
                      height: 1.7, fontSize: 14,
                      color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
                    ),
                  ),
                ),
                BidHistoryList(auctionId: auction.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
