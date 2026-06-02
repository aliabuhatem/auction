import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/usecases/get_auctions_usecase.dart';
import '../../domain/usecases/watch_auctions_usecase.dart';

part 'auction_list_event.dart';
part 'auction_list_state.dart';

class AuctionListBloc extends Bloc<AuctionListEvent, AuctionListState> {
  final GetAuctionsUseCase getAuctions;
  final WatchAuctionsUseCase watchAuctions;

  StreamSubscription<List<AuctionEntity>>? _streamSub;

  AuctionListBloc({required this.getAuctions, required this.watchAuctions})
      : super(AuctionListInitial()) {
    on<LoadAuctions>(_onLoad);
    on<LoadMoreAuctions>(_onLoadMore);
    on<RefreshAuctions>(_onRefresh);
    on<FilterByCategory>(_onFilter);
    on<SearchAuctions>(_onSearch);
    on<AuctionListStreamUpdated>(_onStreamUpdate);
    on<AuctionListStreamFailed>(_onStreamFailed);
  }

  Future<void> _onLoad(LoadAuctions e, Emitter<AuctionListState> emit) async {
    emit(AuctionListLoading());
    _subscribeToStream(null);
  }

  Future<void> _onRefresh(RefreshAuctions e, Emitter<AuctionListState> emit) async {
    final cat = state is AuctionListLoaded
        ? (state as AuctionListLoaded).selectedCategory
        : null;
    emit(AuctionListLoading());
    _subscribeToStream(cat);
  }

  Future<void> _onLoadMore(LoadMoreAuctions e, Emitter<AuctionListState> emit) async {
    if (state is! AuctionListLoaded) return;
    final s = state as AuctionListLoaded;
    if (!s.hasMore || s.isLoadingMore) return;
    emit(s.copyWith(isLoadingMore: true));
    final result = await getAuctions(
        GetAuctionsParams(category: s.selectedCategory, page: s.currentPage + 1));
    result.fold(
      (f) => emit(AuctionListLoaded(
          auctions: s.auctions,
          hasMore: false,
          currentPage: s.currentPage,
          selectedCategory: s.selectedCategory)),
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
    _subscribeToStream(e.category);
  }

  Future<void> _onSearch(SearchAuctions e, Emitter<AuctionListState> emit) async {
    // Search is one-shot (text filtering) — pause the live stream while active
    _streamSub?.cancel();
    _streamSub = null;
    emit(AuctionListLoading());
    final result = await getAuctions(GetAuctionsParams(query: e.query));
    result.fold(
      (f) => emit(AuctionListError(f.message)),
      (list) => emit(AuctionListLoaded(
          auctions: list, hasMore: false, currentPage: 1, selectedCategory: null)),
    );
  }

  void _onStreamUpdate(
      AuctionListStreamUpdated e, Emitter<AuctionListState> emit) {
    final cat = state is AuctionListLoaded
        ? (state as AuctionListLoaded).selectedCategory
        : null;
    emit(AuctionListLoaded(
      auctions: e.auctions,
      endingSoonAuctions: e.auctions.where((a) => a.isEnding).toList(),
      featuredAuctions: e.auctions.take(3).toList(),
      hasMore: e.auctions.length == 20,
      currentPage: 1,
      selectedCategory: cat,
    ));
  }

  void _onStreamFailed(
          AuctionListStreamFailed e, Emitter<AuctionListState> emit) =>
      emit(AuctionListError(e.error));

  void _subscribeToStream(AuctionCategory? category) {
    _streamSub?.cancel();
    _streamSub = watchAuctions(category: category).listen(
      (auctions) => add(AuctionListStreamUpdated(auctions)),
      onError: (e) => add(AuctionListStreamFailed(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
