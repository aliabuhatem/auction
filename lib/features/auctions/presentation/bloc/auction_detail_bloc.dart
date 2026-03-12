import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/usecases/get_auction_detail_usecase.dart';
import '../../domain/usecases/watch_auction_usecase.dart';
import '../../domain/repositories/auction_repository.dart';

part 'auction_detail_event.dart';
part 'auction_detail_state.dart';

class AuctionDetailBloc
    extends Bloc<AuctionDetailEvent, AuctionDetailState> {

  final GetAuctionDetailUseCase getAuctionDetail;
  final WatchAuctionUseCase     watchAuction;
  final AuctionRepository       repository;

  StreamSubscription<AuctionEntity>? _streamSub;

  AuctionDetailBloc({
    required this.getAuctionDetail,
    required this.watchAuction,
    required this.repository,
  }) : super(AuctionDetailInitial()) {
    on<LoadAuctionDetail>     (_onLoad);
    on<RefreshAuctionDetail>  (_onRefresh);
    on<AuctionDetailStreamUpdated>(_onStreamUpdate);
    on<ToggleAuctionAlarm>    (_onToggleAlarm);
    on<ToggleAuctionWatchlist>(_onToggleWatchlist);
  }

  Future<void> _onLoad(
    LoadAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    emit(AuctionDetailLoading());
    final result =
        await getAuctionDetail(GetAuctionDetailParams(id: event.auctionId));

    result.fold(
      (failure) => emit(AuctionDetailError(failure.message)),
      (auction) {
        emit(AuctionDetailLoaded(auction: auction));
        _subscribeToStream(event.auctionId);
      },
    );
  }

  Future<void> _onRefresh(
    RefreshAuctionDetail event,
    Emitter<AuctionDetailState> emit,
  ) async {
    if (state is AuctionDetailLoaded) {
      emit((state as AuctionDetailLoaded).copyWith(isRefreshing: true));
    }
    final result =
        await getAuctionDetail(GetAuctionDetailParams(id: event.auctionId));
    result.fold(
      (failure) => emit(AuctionDetailError(failure.message)),
      (auction) {
        final prev = state is AuctionDetailLoaded
            ? state as AuctionDetailLoaded
            : null;
        emit(AuctionDetailLoaded(
          auction:       auction,
          alarmSet:      prev?.alarmSet      ?? false,
          isWatchlisted: prev?.isWatchlisted ?? false,
        ));
      },
    );
  }

  void _onStreamUpdate(
    AuctionDetailStreamUpdated event,
    Emitter<AuctionDetailState> emit,
  ) {
    if (state is AuctionDetailLoaded) {
      emit((state as AuctionDetailLoaded).copyWith(auction: event.auction));
    }
  }

  Future<void> _onToggleAlarm(
    ToggleAuctionAlarm event,
    Emitter<AuctionDetailState> emit,
  ) async {
    if (state is! AuctionDetailLoaded) return;
    final current = state as AuctionDetailLoaded;
    final nowSet  = !current.alarmSet;

    emit(current.copyWith(alarmSet: nowSet));

    final result = nowSet
        ? await repository.setAuctionAlarm(event.auctionId)
        : await repository.removeAuctionAlarm(event.auctionId);

    result.fold((_) => emit(current), (_) {});
  }

  Future<void> _onToggleWatchlist(
    ToggleAuctionWatchlist event,
    Emitter<AuctionDetailState> emit,
  ) async {
    if (state is! AuctionDetailLoaded) return;
    final current = state as AuctionDetailLoaded;

    emit(current.copyWith(isWatchlisted: !current.isWatchlisted));

    final result = await repository.watchlistAuction(event.auctionId);
    result.fold((_) => emit(current), (_) {});
  }

  void _subscribeToStream(String auctionId) {
    _streamSub?.cancel();
    _streamSub = watchAuction(auctionId)
        .listen((auction) => add(AuctionDetailStreamUpdated(auction)));
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
