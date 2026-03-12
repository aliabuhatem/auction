import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/bidding_bloc.dart';
import '../widgets/bid_history_list.dart';
import '../widgets/auction_timer_badge.dart';
import '../../../../core/widgets/bid_button.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/app_colors.dart';

class AuctionDetailPage extends StatefulWidget {
  final String auctionId;
  const AuctionDetailPage({super.key, required this.auctionId});
  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> with SingleTickerProviderStateMixin {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Bod geplaatst! 🎉')]),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is BiddingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is BiddingLoaded && state.wasOutbid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Je bent overboden! Bied opnieuw.'), backgroundColor: Colors.orange),
          );
        }
      },
      builder: (context, state) {
        if (state is BiddingLoading) return Scaffold(appBar: AppBar(), body: const AuctionDetailShimmer());
        if (state is BiddingError) return Scaffold(body: Center(child: Text(state.message)));

        final auction = switch (state) {
          BiddingLoaded(:final auction) => auction,
          BiddingPlacing(:final auction) => auction,
          BiddingSuccess(:final auction) => auction,
          BiddingFailed(:final auction) => auction,
          _ => null,
        };
        if (auction == null) return const Scaffold(body: AuctionDetailShimmer());

        final isPlacing = state is BiddingPlacing;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageGallery(auction.imageUrls),
                ),
                actions: [
                  IconButton(
                    icon: Icon(auction.isWatchlisted ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                    onPressed: () => context.read<BiddingBloc>().add(ToggleWatchlist(auction.id)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => Share.share('Check deze veiling: ${auction.title}'),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(auction.category.name, style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      const SizedBox(height: 10),
                      Text(auction.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(auction.location, style: const TextStyle(color: Colors.grey)),
                      ]),
                      const SizedBox(height: 20),
                      _buildBiddingBox(auction, isPlacing, context),
                      const SizedBox(height: 20),
                      // Retail value row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statItem('Waarde', CurrencyFormatter.format(auction.retailValue), Colors.grey),
                          _statItem('Jij bespaart', '-${auction.savingsPercent.toStringAsFixed(0)}%', Colors.green),
                          _statItem('Biedingen', '${auction.bidCount}', AppColors.primaryRed),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tabs
                      TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryRed,
                        labelColor: AppColors.primaryRed,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [Tab(text: 'Beschrijving'), Tab(text: 'Biedingen')],
                      ),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(auction.description, style: const TextStyle(height: 1.6, color: AppColors.textSecondary)),
                            ),
                            BidHistoryList(auctionId: auction.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGallery(List<String> urls) {
    if (urls.isEmpty) return Container(color: Colors.grey[300]);
    return Stack(
      children: [
        PageView.builder(
          itemCount: urls.length,
          onPageChanged: (i) => setState(() => _imageIndex = i),
          itemBuilder: (_, i) => Image.asset(
            urls[i],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
              );
            },
          ),
          // CachedNetworkImage(imageUrl: urls[i], fit: BoxFit.cover),
        ),
        if (urls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(urls.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _imageIndex ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _imageIndex ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
      ],
    );
  }

  Widget _buildBiddingBox(auction, bool isPlacing, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Huidig bod', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(CurrencyFormatter.format(auction.currentBid),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primaryRed)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Eindigt over', style: TextStyle(color: Colors.grey, fontSize: 12)),
                AuctionTimerBadge(endsAt: auction.endsAt, large: true),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          BidButton(
            nextBid: auction.currentBid + 1.0,
            isLoading: isPlacing,
            onTap: isPlacing ? null : () {
              context.read<BiddingBloc>().add(SubmitBid(
                auctionId: auction.id,
                amount: auction.currentBid + 1.0,
              ));
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.read<BiddingBloc>().add(SetAlarm(auction.id)),
            icon: const Icon(Icons.alarm, size: 18),
            label: const Text('Stel alarm in'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: Colors.grey),
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
    ]);
  }
}
