import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auctions/domain/entities/auction_entity.dart';
import '../../../auctions/presentation/bloc/auction_list_bloc.dart';
import '../../../auctions/presentation/widgets/auction_grid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_shimmer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<String> _history = [];
  AuctionCategory? _selectedCategory;

  static const _prefKey  = 'search_history';
  static const _maxItems = 8;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _history = prefs.getStringList(_prefKey) ?? []);
  }

  Future<void> _addToHistory(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = [q, ..._history.where((h) => h != q)].take(_maxItems).toList();
    await prefs.setStringList(_prefKey, updated);
    if (mounted) setState(() => _history = updated);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    if (mounted) setState(() => _history = []);
  }

  void _runSearch(String query, {AuctionCategory? category}) {
    _searchController.text = query;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
    if (query.trim().isNotEmpty) _addToHistory(query.trim());
    context.read<AuctionListBloc>().add(
          SearchAuctions(query, category: category ?? _selectedCategory));
  }

  void _selectCategory(AuctionCategory? cat) {
    setState(() => _selectedCategory = cat);
    final q = _searchController.text;
    if (q.trim().isNotEmpty) {
      context.read<AuctionListBloc>().add(SearchAuctions(q, category: cat));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: AppStrings.searchHint(context),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                        context
                            .read<AuctionListBloc>()
                            .add(const SearchAuctions(''));
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
              _debounce?.cancel();
              if (value.trim().isEmpty) {
                context.read<AuctionListBloc>().add(const SearchAuctions(''));
                return;
              }
              _debounce = Timer(const Duration(milliseconds: 400), () {
                _addToHistory(value.trim());
                context.read<AuctionListBloc>().add(SearchAuctions(value));
              });
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) _runSearch(value.trim());
            },
          ),
        ),
      ),
      body: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          if (_searchController.text.isEmpty) return _buildInitial(context);
          if (state is AuctionListLoading) return const AuctionGridShimmer();
          if (state is AuctionListLoaded) {
            if (state.auctions.isEmpty) return _buildEmpty(context);
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
          return _buildInitial(context);
        },
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64,
                color: isDark ? AppColors.darkBorder : AppColors.textHint),
            const SizedBox(height: 16),
            Text(AppStrings.searchPrompt(context),
                style: TextStyle(
                    color: isDark ? const Color(0xFF8892A4) : AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.recentSearches(context),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? const Color(0xFF8892A4) : AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: _clearHistory,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
              ),
              child: Text(AppStrings.clearHistory(context),
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _history.map((q) {
            return GestureDetector(
              onTap: () => _runSearch(q),
              child: Chip(
                avatar: const Icon(Icons.history,
                    size: 16, color: AppColors.primaryRed),
                label: Text(q,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13)),
                backgroundColor:
                    isDark ? AppColors.darkCard : Colors.grey[100],
                side: BorderSide.none,
                deleteIcon: const Icon(Icons.close, size: 14),
                deleteIconColor: AppColors.textHint,
                onDeleted: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final updated =
                      _history.where((h) => h != q).toList();
                  await prefs.setStringList(_prefKey, updated);
                  if (mounted) setState(() => _history = updated);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(AppStrings.noResults(context),
              style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
