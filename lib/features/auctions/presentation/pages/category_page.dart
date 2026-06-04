import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auction_list_bloc.dart';
import '../widgets/auction_grid.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../domain/entities/auction_entity.dart';

class CategoryPage extends StatefulWidget {
  final AuctionCategory? category;
  const CategoryPage({super.key, this.category});
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AuctionListBloc>().add(FilterByCategory(category: widget.category));
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

  @override
  Widget build(BuildContext context) {
    final title = widget.category?.label ?? 'Alle veilingen';
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          if (state is AuctionListLoading) return const AuctionGridShimmer();
          if (state is AuctionListLoaded) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<AuctionListBloc>().add(FilterByCategory(category: widget.category)),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  AuctionGrid(
                    auctions: state.auctions,
                    hasMore: state.hasMore,
                    isLoadingMore: state.isLoadingMore,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          }
          if (state is AuctionListError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
