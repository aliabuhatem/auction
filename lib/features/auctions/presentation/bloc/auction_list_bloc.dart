import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/usecases/get_auctions_usecase.dart';

part 'auction_list_event.dart';
part 'auction_list_state.dart';

class AuctionListBloc extends Bloc<AuctionListEvent, AuctionListState> {
  final GetAuctionsUseCase getAuctions;

  AuctionListBloc({required this.getAuctions}) : super(AuctionListInitial()) {
    on<LoadAuctions>(_onLoad);
    on<LoadMoreAuctions>(_onLoadMore);
    on<RefreshAuctions>(_onRefresh);
    on<FilterByCategory>(_onFilter);
    on<SearchAuctions>(_onSearch);
  }

  Future<void> _onLoad(LoadAuctions e, Emitter<AuctionListState> emit) async {
    emit(AuctionListLoading());
    await _fetch(emit, category: null, page: 1);
  }

  Future<void> _onRefresh(RefreshAuctions e, Emitter<AuctionListState> emit) async {
    final cat = state is AuctionListLoaded ? (state as AuctionListLoaded).selectedCategory : null;
    emit(AuctionListLoading());
    await _fetch(emit, category: cat, page: 1);
  }

  Future<void> _onLoadMore(LoadMoreAuctions e, Emitter<AuctionListState> emit) async {
    if (state is! AuctionListLoaded) return;
    final s = state as AuctionListLoaded;
    if (!s.hasMore || s.isLoadingMore) return;
    emit(s.copyWith(isLoadingMore: true));
    final result = await getAuctions(GetAuctionsParams(category: s.selectedCategory, page: s.currentPage + 1));
    result.fold(
      (f) => emit(AuctionListLoaded(auctions: s.auctions, hasMore: false, currentPage: s.currentPage, selectedCategory: s.selectedCategory)),
      (more) => emit(AuctionListLoaded(
        auctions: [...s.auctions, ...more],
        hasMore: more.length == 20,
        currentPage: s.currentPage + 1,
        selectedCategory: s.selectedCategory,
      )),
    );
  }

  Future<void> _onFilter(FilterByCategory e, Emitter<AuctionListState> emit) async {
    emit(AuctionListLoading());
    await _fetch(emit, category: e.category, page: 1);
  }

  Future<void> _onSearch(SearchAuctions e, Emitter<AuctionListState> emit) async {
    emit(AuctionListLoading());
    final result = await getAuctions(GetAuctionsParams(query: e.query));
    result.fold(
      (f) => emit(AuctionListError(f.message)),
      (list) => emit(AuctionListLoaded(auctions: list, hasMore: false, currentPage: 1, selectedCategory: null)),
    );
  }

  Future<void> _fetch(Emitter<AuctionListState> emit, {AuctionCategory? category, int page = 1}) async {
    final result = await getAuctions(GetAuctionsParams(category: category, page: page));
    result.fold(
      (f) => emit(AuctionListError(f.message)),
      (list) => emit(AuctionListLoaded(
        auctions: list,
        endingSoonAuctions: list.where((a) => a.isEnding).toList(),
        featuredAuctions: list.take(3).toList(),
        hasMore: list.length == 20,
        currentPage: page,
        selectedCategory: category,
      )),
    );
  }
}
