import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/auction_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../../domain/usecases/get_auction_detail_usecase.dart';
import '../../domain/usecases/place_bid_usecase.dart';
import '../../domain/usecases/watch_auction_usecase.dart';

part 'bidding_event.dart';
part 'bidding_state.dart';

class BiddingBloc extends Bloc<BiddingEvent, BiddingState> {
  final GetAuctionDetailUseCase getAuctionDetail;
  final PlaceBidUseCase placeBid;
  final WatchAuctionUseCase watchAuction;
  final AuctionRepository repository;
  StreamSubscription<AuctionEntity>? _sub;

  BiddingBloc({
    required this.getAuctionDetail,
    required this.placeBid,
    required this.watchAuction,
    required this.repository,
  }) : super(BiddingInitial()) {
    on<LoadAuctionForBidding>(_onLoad);
    on<AuctionStreamUpdate>(_onUpdate);
    on<SubmitBid>(_onSubmitBid);
    on<ToggleWatchlist>(_onWatchlist);
    on<SetAlarm>(_onAlarm);
  }

  Future<void> _onLoad(LoadAuctionForBidding e, Emitter<BiddingState> emit) async {
    emit(BiddingLoading());
    final result = await getAuctionDetail(GetAuctionDetailParams(id: e.auctionId));
    result.fold(
      (f) => emit(BiddingError(f.message)),
      (auction) {
        emit(BiddingLoaded(auction: auction));
        _sub?.cancel();
        _sub = watchAuction(e.auctionId).listen((a) => add(AuctionStreamUpdate(a)));
      },
    );
  }

  void _onUpdate(AuctionStreamUpdate e, Emitter<BiddingState> emit) {
    if (state is BiddingLoaded) {
      final s = state as BiddingLoaded;
      final outbid = s.auction.currentBid < e.auction.currentBid;
      emit(BiddingLoaded(auction: e.auction, wasOutbid: outbid && s.isMine, isMine: s.isMine));
    }
  }

  Future<void> _onSubmitBid(SubmitBid e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    emit(BiddingPlacing(auction: s.auction));
    final result = await placeBid(PlaceBidParams(auctionId: e.auctionId, bidAmount: e.amount));
    result.fold(
      (f) => emit(BiddingFailed(auction: s.auction, error: f.message)),
      (_) => emit(BiddingSuccess(auction: s.auction)),
    );
  }

  Future<void> _onWatchlist(ToggleWatchlist e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    final wasWatchlisted = s.auction.isWatchlisted;

    // Optimistic update
    emit(BiddingLoaded(
      auction: _copyAuctionWithWatchlist(s.auction, !wasWatchlisted),
      isMine: s.isMine,
    ));

    final result = await repository.watchlistAuction(e.auctionId);
    result.fold(
      (f) {
        // Revert on failure
        emit(BiddingLoaded(
          auction: _copyAuctionWithWatchlist(s.auction, wasWatchlisted),
          isMine: s.isMine,
        ));
      },
      (_) {}, // optimistic update stays
    );
  }

  Future<void> _onAlarm(SetAlarm e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    final isAlarmed = s.isAlarmed;

    // Optimistic update
    emit(BiddingLoaded(
      auction: s.auction,
      isMine: s.isMine,
      isAlarmed: !isAlarmed,
    ));

    final result = isAlarmed
        ? await repository.removeAuctionAlarm(e.auctionId)
        : await repository.setAuctionAlarm(e.auctionId);

    result.fold(
      (f) {
        // Revert on failure
        emit(BiddingLoaded(auction: s.auction, isMine: s.isMine, isAlarmed: isAlarmed));
      },
      (_) {},
    );
  }

  // AuctionEntity is immutable — copy by creating an AuctionModel copy via its fields
  AuctionEntity _copyAuctionWithWatchlist(AuctionEntity a, bool watchlisted) {
    return AuctionEntity(
      id: a.id,
      title: a.title,
      description: a.description,
      imageUrl: a.imageUrl,
      imageUrls: a.imageUrls,
      currentBid: a.currentBid,
      startingBid: a.startingBid,
      bidCount: a.bidCount,
      endsAt: a.endsAt,
      status: a.status,
      category: a.category,
      location: a.location,
      retailValue: a.retailValue,
      isWatchlisted: watchlisted,
      winnerId: a.winnerId,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
