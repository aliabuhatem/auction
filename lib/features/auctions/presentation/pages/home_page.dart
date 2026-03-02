import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auction_list_bloc.dart';
import '../widgets/auction_grid.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/auction_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();

  static final _cats = [
    (null, '🏷️', AppStrings.all),
    (AuctionCategory.vacation, '🏖️', AppStrings.catVacation),
    (AuctionCategory.beauty, '💅', AppStrings.catBeauty),
    (AuctionCategory.sauna, '🧖', AppStrings.catSauna),
    (AuctionCategory.food, '🍽️', AppStrings.catFood),
    (AuctionCategory.experiences, '🎭', AppStrings.catExperiences),
    (AuctionCategory.products, '📦', AppStrings.catProducts),
    (AuctionCategory.sports, '⚽', AppStrings.catSports),
    (AuctionCategory.wellness, '🧘', AppStrings.catWellness),
    (AuctionCategory.dayTrips, '🚂', AppStrings.catDayTrips),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AuctionListBloc>().add(LoadAuctions());
    _scrollController.addListener(() {
      if (_isBottom) context.read<AuctionListBloc>().add(LoadMoreAuctions());
    });
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset >= (_scrollController.position.maxScrollExtent * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            title: const Row(
              children: [
                Icon(Icons.gavel, color: AppColors.primaryRed, size: 28),
                SizedBox(width: 8),
                Text(AppStrings.appName,
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 20)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.textPrimary),
                onPressed: () => context.push('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryBarDelegate(cats: _cats),
          ),
        ],
        body: BlocBuilder<AuctionListBloc, AuctionListState>(
          builder: (context, state) {
            if (state is AuctionListLoading) return const AuctionGridShimmer();
            if (state is AuctionListError) return _buildError(state.message);
            if (state is AuctionListLoaded) return _buildContent(state);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(AuctionListLoaded state) {
    return RefreshIndicator(
      color: AppColors.primaryRed,
      onRefresh: () async => context.read<AuctionListBloc>().add(RefreshAuctions()),
      child: CustomScrollView(
        slivers: [
          if (state.endingSoonAuctions.isNotEmpty) ...[
            _sectionHeader(AppStrings.endingSoon),
            SliverToBoxAdapter(child: AuctionHorizontalList(auctions: state.endingSoonAuctions)),
          ],
          _sectionHeader(AppStrings.allAuctions),
          AuctionGrid(auctions: state.auctions, hasMore: state.hasMore, isLoadingMore: state.isLoadingMore),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AuctionListBloc>().add(LoadAuctions()),
            child: const Text(AppStrings.tryAgain),
          ),
        ],
      ),
    );
  }
}

class _CategoryBarDelegate extends SliverPersistentHeaderDelegate {
  final List cats;
  const _CategoryBarDelegate({required this.cats});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          final sel = state is AuctionListLoaded ? state.selectedCategory : null;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            children: cats.map<Widget>((c) {
              return CategoryChip(
                emoji: c.$2 as String,
                label: c.$3 as String,
                isSelected: sel == c.$1,
                onTap: () => context.read<AuctionListBloc>().add(FilterByCategory(category: c.$1 as AuctionCategory?)),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryBarDelegate old) => false;
}
