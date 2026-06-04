import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/app_routes.dart';
import '../bloc/bidding_bloc.dart';
import '../../domain/entities/auction_entity.dart';
import '../widgets/bid_history_list.dart';
import '../../../../core/widgets/bid_button.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

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
          final msg = state.isAutoBid
              ? '🤖 Auto-bod geplaatst: ${CurrencyFormatter.format(state.auction.currentBid)}'
              : AppStrings.bidPlaced(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        } else if (state is BiddingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ));
        } else if (state is BiddingLoaded && state.wasOutbid) {
          HapticFeedback.heavyImpact();
          // Capture bid details before the snackbar is shown.
          final auctionId = state.auction.id;
          final nextBid   = state.auction.nextMinBid;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(AppStrings.outbid(context),
                  style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            action: SnackBarAction(
              label: AppStrings.bidBackLabel(context),
              textColor: Colors.white,
              onPressed: () => context.read<BiddingBloc>().add(
                    SubmitBid(auctionId: auctionId, amount: nextBid),
                  ),
            ),
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

        if (state is BiddingWon) {
          return _WinScreen(auction: state.auction);
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

        final biddingLoaded = state is BiddingLoaded ? state : null;
        final biddingSuccess = state is BiddingSuccess ? state : null;

        final isMine     = biddingLoaded?.isMine     ?? biddingSuccess?.isMine     ?? false;
        final isAlarmed  = biddingLoaded?.isAlarmed  ?? biddingSuccess?.isAlarmed  ?? false;
        final autoBidMax = biddingLoaded?.autoBidMax ?? biddingSuccess?.autoBidMax;
        final wasOutbid  = biddingLoaded?.wasOutbid  ?? false;
        final showExt    = biddingLoaded?.showExtensionBanner ?? false;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
            extendBodyBehindAppBar: true,
            body: CustomScrollView(
              slivers: [
                // ── Immersive image app bar ─────────────────────────────────
                SliverAppBar(
                  expandedHeight: 320,
                  pinned:         true,
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
                          Share.share(AppStrings.shareAuction(context, auction.title)),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // ── Body ───────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(auction: auction, isDark: isDark),
                      // Extension banner
                      if (showExt) _ExtensionBanner(seconds: auction.extensionSeconds),
                      // Winning / outbid status bar
                      if (isMine || wasOutbid)
                        _StatusBar(
                          isWinning:  isMine && !wasOutbid,
                          wasOutbid:  wasOutbid,
                          hasAutoBid: autoBidMax != null,
                        ),
                      _BidPanel(
                        auction:    auction,
                        isPlacing:  isPlacing,
                        isDark:     isDark,
                        isMine:     isMine,
                        wasOutbid:  wasOutbid,
                        autoBidMax: autoBidMax,
                        isAlarmed:  isAlarmed,
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

// ── Extension banner ──────────────────────────────────────────────────────────

class _ExtensionBanner extends StatelessWidget {
  final int seconds;
  const _ExtensionBanner({required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withValues(alpha: 0.35),
            blurRadius: 12, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.auctionExtended(context, seconds),
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Winning / Outbid status bar ───────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final bool isWinning;
  final bool wasOutbid;
  final bool hasAutoBid;
  const _StatusBar({required this.isWinning, required this.wasOutbid, required this.hasAutoBid});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    if (isWinning && hasAutoBid) {
      bg = const Color(0xFFFFF9E6); fg = const Color(0xFFF59E0B);
      icon = Icons.bolt_rounded;
      label = AppStrings.autoBidActiveLeading(context);
    } else if (isWinning) {
      bg = AppColors.successLight; fg = AppColors.success;
      icon = Icons.emoji_events_rounded;
      label = AppStrings.youAreWinning(context);
    } else {
      bg = AppColors.errorLight; fg = AppColors.error;
      icon = Icons.warning_amber_rounded;
      label = AppStrings.youWereOutbid(context);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13))),
        ],
      ),
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
    required this.imageUrls, required this.imageIndex, required this.onPageChanged,
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
            loadingBuilder: (_, child, p) =>
                p == null ? child : Container(color: AppColors.backgroundGrey,
                    child: const Center(child: CircularProgressIndicator(
                        color: AppColors.primaryRed, strokeWidth: 2))),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.imageOverlay)),
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 20, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == imageIndex ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == imageIndex ? Colors.white : Colors.white.withValues(alpha: 0.5),
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
    final textPrimary   = isDark ? AppColors.textOnDark   : AppColors.textPrimaryLight;
    final textSecondary = isDark ? const Color(0xFF8892A4) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(auction.category.label.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.primaryRed, fontWeight: FontWeight.w700,
                        fontSize: 11, letterSpacing: 0.8)),
              ),
              const SizedBox(width: 8),
              // LIVE badge
              if (auction.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('LIVE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                              fontSize: 11, letterSpacing: 0.8)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(auction.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  color: textPrimary, letterSpacing: -0.3, height: 1.2)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: textSecondary),
              const SizedBox(width: 4),
              Text(auction.location, style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(width: 12),
              Icon(Icons.people_outline, size: 15, color: textSecondary),
              const SizedBox(width: 4),
              Text(AppStrings.watcherCount(context, auction.watchers),
                  style: TextStyle(color: textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Bid Panel ─────────────────────────────────────────────────────────────────

class _BidPanel extends StatefulWidget {
  final AuctionEntity auction;
  final bool isPlacing;
  final bool isDark;
  final bool isMine;
  final bool wasOutbid;
  final double? autoBidMax;
  final bool isAlarmed;

  const _BidPanel({
    required this.auction,
    required this.isPlacing,
    required this.isDark,
    required this.isMine,
    required this.wasOutbid,
    required this.autoBidMax,
    required this.isAlarmed,
  });

  @override
  State<_BidPanel> createState() => _BidPanelState();
}

class _BidPanelState extends State<_BidPanel> with SingleTickerProviderStateMixin {
  final TextEditingController _customCtrl = TextEditingController();
  bool _showAutoBid   = false;
  bool _showCustom    = false;
  double? _selectedAmount;

  // Bid price flash animation
  late AnimationController _flashCtrl;
  late Animation<Color?>    _flashColor;
  double _prevBid = 0;

  @override
  void initState() {
    super.initState();
    _prevBid  = widget.auction.currentBid;
    _flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _flashColor = ColorTween(
      begin: const Color(0xFFFF6B00),
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_BidPanel old) {
    super.didUpdateWidget(old);
    if (widget.auction.currentBid != _prevBid) {
      _prevBid = widget.auction.currentBid;
      _flashCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  void _placeBid(double amount) {
    HapticFeedback.mediumImpact();
    context.read<BiddingBloc>().add(SubmitBid(
      auctionId: widget.auction.id,
      amount:    amount,
    ));
  }

  void _setAutoBid() {
    final max = double.tryParse(_customCtrl.text.replaceAll(',', '.'));
    if (max == null || max <= widget.auction.currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.invalidMaxBid(context)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    context.read<BiddingBloc>().add(SetAutoBid(
      auctionId: widget.auction.id,
      maxAmount: max,
    ));
    setState(() => _showAutoBid = false);
    _customCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    final isDark  = widget.isDark;
    final minBid  = auction.nextMinBid;
    final isActive = auction.isLive;

    final cardColor  = isDark ? AppColors.glassFill : Colors.white;
    final borderCol  = isDark ? AppColors.goldBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.textOnDark : AppColors.textPrimaryLight;
    final textSec    = isDark ? const Color(0xFF8892A4) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color:        cardColor,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: borderCol, width: isDark ? 1 : 1.5),
          boxShadow: isDark ? AppColors.glassShadow : [const BoxShadow(
              color: AppColors.cardShadow, blurRadius: 24, offset: Offset(0, 8))],
        ),
        child: Column(
          children: [
            // ── Current bid + Countdown ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current bid with flash
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.currentBid(context),
                            style: TextStyle(color: textSec, fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        AnimatedBuilder(
                          animation: _flashColor,
                          builder: (_, __) => Text(
                            CurrencyFormatter.format(auction.currentBid),
                            style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w900,
                              letterSpacing: -0.5, height: 1,
                              color: _flashColor.value?.withValues(alpha: 1) ??
                                  AppColors.primaryRed,
                              shadows: _flashCtrl.value > 0 ? [
                                Shadow(
                                  color: AppColors.primaryRed
                                      .withValues(alpha: _flashCtrl.value * 0.4),
                                  blurRadius: 8,
                                ),
                              ] : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.bidCountMin(context, auction.bidCount,
                              CurrencyFormatter.format(auction.minBidIncrement)),
                          style: TextStyle(color: textSec, fontSize: 11,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  // Countdown blocks
                  _CountdownBlocks(endsAt: auction.endsAt),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),

            // ── Quick bid buttons ─────────────────────────────────────────
            if (isActive) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.quickBid(context), style: TextStyle(
                        color: textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QuickBidChip(
                          label: AppStrings.minBidLabel(context),
                          amount: minBid,
                          isSelected: _selectedAmount == minBid,
                          onTap: () => setState(() => _selectedAmount = minBid),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _QuickBidChip(
                          label: '+€5',
                          amount: minBid + 5,
                          isSelected: _selectedAmount == minBid + 5,
                          onTap: () => setState(() => _selectedAmount = minBid + 5),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _QuickBidChip(
                          label: '+€10',
                          amount: minBid + 10,
                          isSelected: _selectedAmount == minBid + 10,
                          onTap: () => setState(() => _selectedAmount = minBid + 10),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _QuickBidChip(
                          label: '+€25',
                          amount: minBid + 25,
                          isSelected: _selectedAmount == minBid + 25,
                          onTap: () => setState(() => _selectedAmount = minBid + 25),
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Custom amount toggle
                    GestureDetector(
                      onTap: () => setState(() => _showCustom = !_showCustom),
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 14, color: textSec),
                          const SizedBox(width: 4),
                          Text(AppStrings.customAmount(context),
                              style: TextStyle(color: textSec, fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),

                    if (_showCustom) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixText: '€ ',
                                hintText: CurrencyFormatter.decimal(minBid),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryRed, width: 1.5),
                                ),
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurface : AppColors.backgroundGrey,
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, color: textPrimary),
                              onSubmitted: (v) {
                                final amt = double.tryParse(v.replaceAll(',', '.'));
                                if (amt != null) setState(() => _selectedAmount = amt);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final amt = double.tryParse(
                                  _customCtrl.text.replaceAll(',', '.'));
                              if (amt != null) setState(() => _selectedAmount = amt);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(64, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text('OK',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Main bid CTA ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BidButton(
                  nextBid:   _selectedAmount ?? minBid,
                  isLoading: widget.isPlacing,
                  onTap: widget.isPlacing
                      ? null
                      : () => _placeBid(_selectedAmount ?? minBid),
                ),
              ),

              // ── Buy Now ─────────────────────────────────────────────────
              if (auction.buyNowPrice != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () => _placeBid(auction.buyNowPrice!),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
                      foregroundColor: AppColors.primaryRed,
                    ),
                    child: Text(
                      AppStrings.buyNow(context,
                          CurrencyFormatter.format(auction.buyNowPrice!)),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── Auto-bid (proxy bid) ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showAutoBid = !_showAutoBid),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(14),
                          border: widget.autoBidMax != null
                              ? Border.all(
                              color: AppColors.success.withValues(alpha: 0.6),
                              width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Color(0xFFFF6B00), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.autoBidMax != null
                                        ? AppStrings.autoBidActiveMax(context,
                                            CurrencyFormatter.format(widget.autoBidMax!))
                                        : AppStrings.setMaxBid(context),
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700, fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    AppStrings.autoBidSub(context),
                                    style: TextStyle(color: textSec, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _showAutoBid
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: textSec,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showAutoBid) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.autoBidExplain(context),
                              style: TextStyle(color: textSec, fontSize: 12, height: 1.5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _customCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(
                                        decimal: true),
                                    decoration: InputDecoration(
                                      prefixText: '€ ',
                                      hintText: AppStrings.myMaximum(context),
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                        const BorderSide(color: AppColors.border),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.primaryRed, width: 1.5),
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? AppColors.darkCard
                                          : Colors.white,
                                    ),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _setAutoBid,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(90, 48),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12),
                                  ),
                                  child: Text(AppStrings.setBtn(context),
                                      style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                            if (widget.autoBidMax != null) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  context.read<BiddingBloc>().add(
                                      ClearAutoBid(widget.auction.id));
                                  setState(() => _showAutoBid = false);
                                },
                                child: Text(
                                  AppStrings.removeAutoBid(context),
                                  style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Alarm button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: AlarmButton(
                isSet: widget.isAlarmed,
                onTap: () => context.read<BiddingBloc>().add(SetAlarm(widget.auction.id)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Block countdown (DD / HH / MM / SS) ──────────────────────────────────────

class _CountdownBlocks extends StatefulWidget {
  final DateTime endsAt;
  const _CountdownBlocks({required this.endsAt});
  @override
  State<_CountdownBlocks> createState() => _CountdownBlocksState();
}

class _CountdownBlocksState extends State<_CountdownBlocks> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endsAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = widget.endsAt.difference(DateTime.now()));
    });
  }

  @override
  void didUpdateWidget(_CountdownBlocks old) {
    super.didUpdateWidget(old);
    if (old.endsAt != widget.endsAt) {
      setState(() => _remaining = widget.endsAt.difference(DateTime.now()));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lDay  = AppStrings.cdDay(context);
    final lHour = AppStrings.cdHour(context);
    final lMin  = AppStrings.cdMin(context);
    final lSec  = AppStrings.cdSec(context);

    if (_remaining.isNegative || _remaining.inSeconds == 0) {
      return _singleBlock('00', lSec, isUrgent: true);
    }

    final days    = _remaining.inDays;
    final hours   = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final isUrgent  = _remaining.inMinutes < 10;
    final isFlash   = _remaining.inSeconds <= 60;

    final Color blockBg = isUrgent
        ? AppColors.primaryRed.withValues(alpha: 0.10)
        : AppColors.successLight;
    final Color blockFg = isUrgent ? AppColors.primaryRed : AppColors.success;

    Widget block(String val, String lbl) => _block(val, lbl, blockBg, blockFg, isFlash);
    Widget sep() => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(':', style: TextStyle(
          color: blockFg, fontWeight: FontWeight.w900, fontSize: 18)),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (days > 0) ...[
          block(days.toString().padLeft(2, '0'), lDay),
          sep(),
        ],
        block(hours.toString().padLeft(2, '0'), lHour),
        sep(),
        block(minutes.toString().padLeft(2, '0'), lMin),
        sep(),
        block(seconds.toString().padLeft(2, '0'), lSec),
      ],
    );
  }

  Widget _block(String val, String lbl, Color bg, Color fg, bool flash) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w900,
              fontSize: flash ? 17 : 16,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.5,
            ),
            child: Text(val),
          ),
          Text(lbl, style: TextStyle(
              color: fg.withValues(alpha: 0.7), fontSize: 9,
              fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _singleBlock(String val, String lbl, {bool isUrgent = false}) {
    return _block(val, lbl,
        AppColors.primaryRed.withValues(alpha: 0.10), AppColors.primaryRed, false);
  }
}

// ── Quick bid chip ────────────────────────────────────────────────────────────

class _QuickBidChip extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickBidChip({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryRed
                : isDark
                ? AppColors.darkSurface
                : AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryRed
                  : isDark
                  ? AppColors.darkBorder
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                    color: isSelected ? AppColors.textOnGold : AppColors.textSecondary,
                    fontWeight: FontWeight.w600, fontSize: 11,
                  )),
              const SizedBox(height: 2),
              Text(
                CurrencyFormatter.format(amount),
                style: TextStyle(
                  color: isSelected ? AppColors.textOnGold : AppColors.textPrimary,
                  fontWeight: FontWeight.w800, fontSize: 12,
                ),
              ),
            ],
          ),
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
              value: CurrencyFormatter.formatDiscountPercent(
                  auction.retailValue, auction.currentBid),
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
  const _StatCard({required this.label, required this.value,
      required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color:        isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:       isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isDark ? null : [const BoxShadow(
              color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary,
                    height: 1.2)),
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
  const _TabSection({required this.auction, required this.tabController, required this.isDark});

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
              controller:          tabController,
              dividerColor:        Colors.transparent,
              indicator: BoxDecoration(
                gradient:     AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(
                    color: AppColors.primaryShadow, blurRadius: 8, offset: Offset(0, 2))],
              ),
              indicatorSize:        TabBarIndicatorSize.tab,
              labelColor:           Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: AppStrings.tabDescription(context)),
                Tab(text: AppStrings.tabBids(context)),
              ],
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

// ── Win Screen ────────────────────────────────────────────────────────────────

class _WinScreen extends StatefulWidget {
  final AuctionEntity auction;
  const _WinScreen({required this.auction});

  @override
  State<_WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<_WinScreen> {
  bool _findingOrder = false;

  Future<void> _payNow() async {
    setState(() => _findingOrder = true);
    try {
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      if (userUid == null) {
        if (mounted) context.push(AppRoutes.myAuctions);
        return;
      }
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .where('auctionId', isEqualTo: widget.auction.id)
          .where('userId', isEqualTo: userUid)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();
      if (!mounted) return;
      if (snap.docs.isNotEmpty) {
        context.push(AppRoutes.paymentPath(snap.docs.first.id));
      } else {
        context.push(AppRoutes.myAuctions);
      }
    } catch (_) {
      if (mounted) context.push(AppRoutes.myAuctions);
    } finally {
      if (mounted) setState(() => _findingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.youWon(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    auction.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.winningBid(
                        context, CurrencyFormatter.format(auction.currentBid)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _findingOrder ? null : _payNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.success,
                        disabledBackgroundColor: Colors.white60,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      child: _findingOrder
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.success),
                            )
                          : Text(AppStrings.payNow(context)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: Text(
                      AppStrings.backToHome(context),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
