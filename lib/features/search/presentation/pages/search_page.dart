import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auctions/presentation/bloc/auction_list_bloc.dart';
import '../../../auctions/presentation/widgets/auction_grid.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Zoek een veiling...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              context.read<AuctionListBloc>().add(SearchAuctions(value));
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<AuctionListBloc>().add(const SearchAuctions(''));
            },
          ),
        ],
      ),
      body: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          // If the search field is empty, show the initial state regardless of the bloc state
          if (_searchController.text.isEmpty) {
            return _buildInitial();
          }

          if (state is AuctionListLoading) {
            return const AuctionGridShimmer();
          }
          
          if (state is AuctionListLoaded) {
            if (state.auctions.isEmpty) {
              return _buildEmpty();
            }
            return CustomScrollView(
              slivers: [
                AuctionGrid(
                  auctions: state.auctions,
                  hasMore: false,
                  isLoadingMore: false,
                ),
              ],
            );
          }
          
          if (state is AuctionListError) {
            return Center(child: Text(state.message));
          }

          return _buildInitial();
        },
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Begin met typen om te zoeken', 
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Geen veilingen gevonden', 
            style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
