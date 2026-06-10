// lib/features/auctions/presentation/pages/all_auctions_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../domain/entities/auction_entity.dart';
import '../bloc/auction_list_bloc.dart';
import '../widgets/auction_grid.dart';
import '../widgets/auction_list_tile.dart';

enum _ViewMode { gallery, list }
enum _SortMode { endingTime, popular }

/// /veilingen — browse all auctions with category filter, sort, and a
/// gallery/list view toggle. Reuses [AuctionListBloc] (real-time stream).
class AllAuctionsPage extends StatefulWidget {
  final AuctionCategory? initialCategory;
  const AllAuctionsPage({super.key, this.initialCategory});

  @override
  State<AllAuctionsPage> createState() => _AllAuctionsPageState();
}

class _AllAuctionsPageState extends State<AllAuctionsPage> {
  _ViewMode _view = _ViewMode.gallery;
  _SortMode _sort = _SortMode.endingTime;
  AuctionCategory? _category;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    context.read<AuctionListBloc>().add(FilterByCategory(category: _category));
    _scroll.addListener(() {
      if (_scroll.offset >= _scroll.position.maxScrollExtent * 0.9) {
        context.read<AuctionListBloc>().add(LoadMoreAuctions());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _selectCategory(AuctionCategory? cat) {
    setState(() => _category = cat);
    context.read<AuctionListBloc>().add(FilterByCategory(category: cat));
  }

  List<AuctionEntity> _sorted(List<AuctionEntity> source) {
    final list = [...source];
    switch (_sort) {
      case _SortMode.endingTime:
        list.sort((a, b) => a.endsAt.compareTo(b.endsAt));
      case _SortMode.popular:
        list.sort((a, b) => b.bidCount.compareTo(a.bidCount));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuctionListBloc, AuctionListState>(
          builder: (context, state) {
            final count = state is AuctionListLoaded ? state.auctions.length : 0;
            return Text(
              AppStrings.auctionsCount(context, count),
              style: const TextStyle(fontWeight: FontWeight.w800),
            );
          },
        ),
      ),
      body: Column(
        children: [
          _CategoryBar(selected: _category, onSelect: _selectCategory),
          _Toolbar(
            sort: _sort,
            view: _view,
            onSort: (s) => setState(() => _sort = s),
            onView: (v) => setState(() => _view = v),
          ),
          Expanded(
            child: BlocBuilder<AuctionListBloc, AuctionListState>(
              builder: (context, state) {
                if (state is AuctionListLoading ||
                    state is AuctionListInitial) {
                  return const AuctionGridShimmer();
                }
                if (state is AuctionListError) {
                  return _ErrorState(
                    message: state.message,
                    onRetry: () => context
                        .read<AuctionListBloc>()
                        .add(FilterByCategory(category: _category)),
                  );
                }
                if (state is AuctionListLoaded) {
                  final items = _sorted(state.auctions);
                  return RefreshIndicator(
                    onRefresh: () async => context
                        .read<AuctionListBloc>()
                        .add(FilterByCategory(category: _category)),
                    child: _view == _ViewMode.gallery
                        ? CustomScrollView(
                            controller: _scroll,
                            slivers: [
                              AuctionGrid(
                                auctions: items,
                                hasMore: state.hasMore,
                                isLoadingMore: state.isLoadingMore,
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: AppDimensions.spaceXL),
                              ),
                            ],
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.paddingM,
                              AppDimensions.spaceM,
                              AppDimensions.paddingM,
                              AppDimensions.spaceXL,
                            ),
                            itemCount: items.length,
                            itemBuilder: (_, i) =>
                                AuctionListTile(auction: items[i]),
                          ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category filter chips ─────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final AuctionCategory? selected;
  final ValueChanged<AuctionCategory?> onSelect;
  const _CategoryBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.categoryBarHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
        children: [
          _chip(context, AppStrings.all(context), selected == null,
              () => onSelect(null)),
          for (final cat in AuctionCategory.values)
            _chip(context, cat.label, selected == cat, () => onSelect(cat)),
        ],
      ),
    );
  }

  Widget _chip(
      BuildContext context, String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.spaceS),
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceL, vertical: AppDimensions.spaceS),
            decoration: BoxDecoration(
              gradient: active ? AppColors.goldGradient : null,
              color: active ? null : AppColors.glassFill,
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              border: Border.all(
                color: active ? Colors.transparent : AppColors.glassBorder,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppDimensions.fontM,
                fontWeight: FontWeight.w700,
                color: active
                    ? AppColors.textOnGold
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sort + view toggle ────────────────────────────────────────────────────────
class _Toolbar extends StatelessWidget {
  final _SortMode sort;
  final _ViewMode view;
  final ValueChanged<_SortMode> onSort;
  final ValueChanged<_ViewMode> onView;
  const _Toolbar({
    required this.sort,
    required this.view,
    required this.onSort,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingM, 0, AppDimensions.paddingM, AppDimensions.spaceS),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _SortPill(
                  label: AppStrings.sortEndingTime(context),
                  active: sort == _SortMode.endingTime,
                  onTap: () => onSort(_SortMode.endingTime),
                ),
                const SizedBox(width: AppDimensions.spaceS),
                _SortPill(
                  label: AppStrings.sortPopular(context),
                  active: sort == _SortMode.popular,
                  onTap: () => onSort(_SortMode.popular),
                ),
              ],
            ),
          ),
          _ViewToggleButton(
            icon: Icons.grid_view_rounded,
            active: view == _ViewMode.gallery,
            tooltip: AppStrings.viewGallery(context),
            onTap: () => onView(_ViewMode.gallery),
          ),
          const SizedBox(width: AppDimensions.spaceXS),
          _ViewToggleButton(
            icon: Icons.view_agenda_outlined,
            active: view == _ViewMode.list,
            tooltip: AppStrings.viewList(context),
            onTap: () => onView(_ViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _SortPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SortPill(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceM, vertical: AppDimensions.spaceXS),
        decoration: BoxDecoration(
          color: active
              ? AppColors.gold.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: active ? AppColors.gold : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontS,
            fontWeight: FontWeight.w700,
            color: active
                ? AppColors.gold
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;
  const _ViewToggleButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: active ? AppColors.gold : AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            border: Border.all(
              color: active ? Colors.transparent : AppColors.glassBorder,
            ),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconS,
            color: active
                ? AppColors.textOnGold
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.spaceL),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.spaceL),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(AppStrings.retryBtn(context)),
            ),
          ],
        ),
      ),
    );
  }
}
