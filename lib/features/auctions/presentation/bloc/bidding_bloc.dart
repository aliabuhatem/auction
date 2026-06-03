import 'package:firebase_auth/firebase_auth.dart';
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
    on<AuctionStreamUpdate>  (_onUpdate);
    on<AuctionStreamFailed>  ((e, emit) => emit(BiddingError(e.error)));
    on<SubmitBid>            (_onSubmitBid);
    on<ToggleWatchlist>      (_onWatchlist);
    on<SetAlarm>             (_onAlarm);
    on<SetAutoBid>           (_onSetAutoBid);
    on<ClearAutoBid>         (_onClearAutoBid);
  }

  Future<void> _onLoad(LoadAuctionForBidding e, Emitter<BiddingState> emit) async {
    emit(BiddingLoading());
    final result = await getAuctionDetail(GetAuctionDetailParams(id: e.auctionId));
    result.fold(
      (f) => emit(BiddingError(f.message)),
      (auction) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        emit(BiddingLoaded(
          auction: auction,
          isMine: uid != null && auction.lastBidderId == uid,
        ));
        _sub?.cancel();
        _sub = watchAuction(e.auctionId).listen(
          (a) => add(AuctionStreamUpdate(a)),
          onError: (err) => add(AuctionStreamFailed(err.toString())),
        );
      },
    );
  }

  void _onUpdate(AuctionStreamUpdate e, Emitter<BiddingState> emit) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Winner detection — works regardless of current state
    if (e.auction.status == AuctionStatus.sold &&
        currentUserId != null &&
        e.auction.winnerId == currentUserId) {
      emit(BiddingWon(auction: e.auction));
      return;
    }

    // Transition BiddingSuccess → BiddingLoaded on next stream update
    if (state is BiddingSuccess) {
      final s = state as BiddingSuccess;
      final isMine = currentUserId != null && e.auction.lastBidderId == currentUserId;
      emit(BiddingLoaded(
        auction:    e.auction,
        isMine:     isMine,
        isAlarmed:  s.isAlarmed,
        autoBidMax: s.autoBidMax,
      ));
      return;
    }

    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;

    final prevBid   = s.auction.currentBid;
    final newBid    = e.auction.currentBid;
    final bidRaised = newBid > prevBid;

    final isMine    = currentUserId != null && e.auction.lastBidderId == currentUserId;
    final wasOutbid = bidRaised && s.isMine && !isMine;

    final timeLeft    = e.auction.endsAt.difference(DateTime.now()).inSeconds;
    final wasExtended = bidRaised && timeLeft <= (e.auction.extensionSeconds + 5);

    emit(BiddingLoaded(
      auction:             e.auction,
      wasOutbid:           wasOutbid,
      isMine:              isMine,
      isAlarmed:           s.isAlarmed,
      autoBidMax:          s.autoBidMax,
      showExtensionBanner: wasExtended,
    ));

    // Auto-bid: re-bid if outbid and max allows
    if (wasOutbid && s.autoBidMax != null) {
      final autoAmount = newBid + e.auction.minBidIncrement;
      if (autoAmount <= s.autoBidMax!) {
        add(SubmitBid(auctionId: e.auction.id, amount: autoAmount, isAutoBid: true));
      }
    }
  }

  Future<void> _onSubmitBid(SubmitBid e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    emit(BiddingPlacing(auction: s.auction, isAutoBid: e.isAutoBid));
    final result = await placeBid(
        PlaceBidParams(auctionId: e.auctionId, bidAmount: e.amount));
    result.fold(
      (f) => emit(BiddingFailed(auction: s.auction, error: f.message)),
      (_) => emit(BiddingSuccess(
        auction:    s.auction,
        isAutoBid:  e.isAutoBid,
        isMine:     true,
        autoBidMax: s.autoBidMax,
        isAlarmed:  s.isAlarmed,
      )),
    );
  }

  Future<void> _onWatchlist(ToggleWatchlist e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    final wasWatchlisted = s.auction.isWatchlisted;

    emit(BiddingLoaded(
      auction:    _copyAuction(s.auction, watchlisted: !wasWatchlisted),
      isMine:     s.isMine,
      autoBidMax: s.autoBidMax,
      isAlarmed:  s.isAlarmed,
    ));

    final result = await repository.watchlistAuction(e.auctionId);
    result.fold(
      (f) => emit(BiddingLoaded(
        auction:    _copyAuction(s.auction, watchlisted: wasWatchlisted),
        isMine:     s.isMine,
        autoBidMax: s.autoBidMax,
        isAlarmed:  s.isAlarmed,
      )),
      (_) {},
    );
  }

  Future<void> _onAlarm(SetAlarm e, Emitter<BiddingState> emit) async {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    final isAlarmed = s.isAlarmed;

    emit(BiddingLoaded(
      auction:    s.auction,
      isMine:     s.isMine,
      isAlarmed:  !isAlarmed,
      autoBidMax: s.autoBidMax,
    ));

    final result = isAlarmed
        ? await repository.removeAuctionAlarm(e.auctionId)
        : await repository.setAuctionAlarm(e.auctionId);

    result.fold(
      (f) => emit(BiddingLoaded(
        auction:    s.auction,
        isMine:     s.isMine,
        isAlarmed:  isAlarmed,
        autoBidMax: s.autoBidMax,
      )),
      (_) {},
    );
  }

  void _onSetAutoBid(SetAutoBid e, Emitter<BiddingState> emit) {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    emit(BiddingLoaded(
      auction:    s.auction,
      isMine:     s.isMine,
      isAlarmed:  s.isAlarmed,
      autoBidMax: e.maxAmount,
    ));
  }

  void _onClearAutoBid(ClearAutoBid e, Emitter<BiddingState> emit) {
    if (state is! BiddingLoaded) return;
    final s = state as BiddingLoaded;
    emit(BiddingLoaded(
      auction:    s.auction,
      isMine:     s.isMine,
      isAlarmed:  s.isAlarmed,
      autoBidMax: null,
    ));
  }

  AuctionEntity _copyAuction(AuctionEntity a, {bool? watchlisted}) {
    return AuctionEntity(
      id:               a.id,
      title:            a.title,
      description:      a.description,
      imageUrl:         a.imageUrl,
      imageUrls:        a.imageUrls,
      currentBid:       a.currentBid,
      startingBid:      a.startingBid,
      bidCount:         a.bidCount,
      endsAt:           a.endsAt,
      status:           a.status,
      category:         a.category,
      location:         a.location,
      retailValue:      a.retailValue,
      isWatchlisted:    watchlisted ?? a.isWatchlisted,
      winnerId:         a.winnerId,
      minBidIncrement:  a.minBidIncrement,
      buyNowPrice:      a.buyNowPrice,
      watchers:         a.watchers,
      extensionSeconds: a.extensionSeconds,
      lastBidderId:     a.lastBidderId,
      createdAt:        a.createdAt,
      viewCount:        a.viewCount,
      shippingCost:     a.shippingCost,
      shippingMethod:   a.shippingMethod,
      shippingDays:     a.shippingDays,
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
