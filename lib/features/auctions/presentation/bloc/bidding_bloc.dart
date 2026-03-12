import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/auction_entity.dart';
import '../../domain/usecases/get_auction_detail_usecase.dart';
import '../../domain/usecases/place_bid_usecase.dart';
import '../../domain/usecases/watch_auction_usecase.dart';

part 'bidding_event.dart';
part 'bidding_state.dart';

class BiddingBloc extends Bloc<BiddingEvent, BiddingState> {
  final GetAuctionDetailUseCase getAuctionDetail;
  final PlaceBidUseCase placeBid;
  final WatchAuctionUseCase watchAuction;
  StreamSubscription<AuctionEntity>? _sub;

  BiddingBloc({
    required this.getAuctionDetail,
    required this.placeBid,
    required this.watchAuction,
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
      emit(BiddingLoaded(auction: e.auction, wasOutbid: outbid && s.isMine));
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

  void _onWatchlist(ToggleWatchlist e, Emitter<BiddingState> emit) {}
  void _onAlarm(SetAlarm e, Emitter<BiddingState> emit) {}

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
