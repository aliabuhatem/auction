// Auction detail BLoC

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auction_entity.dart';
import '../../domain/usecases/get_auction_detail_usecase.dart';
import '../../domain/usecases/place_bid_usecase.dart';
import '../../domain/usecases/watch_auction_usecase.dart';
import 'dart:async';

part 'auction_detail_event.dart';
part 'auction_detail_state.dart';

class AuctionDetailBloc extends Bloc<AuctionDetailEvent, AuctionDetailState> {
  final GetAuctionDetailUseCase getAuctionDetail;
  final PlaceBidUseCase placeBid;
  final WatchAuctionUseCase watchAuction;
  StreamSubscription? _auctionSubscription;

  AuctionDetailBloc({
    required this.getAuctionDetail,
    required this.placeBid,
    required this.watchAuction,
  }) : super(AuctionDetailInitial()) {
    on<LoadAuctionDetail>(_onLoadAuctionDetail);
    on<SubscribeToAuction>(_onSubscribeToAuction);
    on<AuctionUpdated>(_onAuctionUpdated);
    on<PlaceBidRequested>(_onPlaceBidRequested);
  }

  Future<void> _onLoadAuctionDetail(
      LoadAuctionDetail event,
      Emitter<AuctionDetailState> emit,
      ) async {
    emit(AuctionDetailLoading());
    final result = await getAuctionDetail(GetAuctionDetailParams(id: event.auctionId));
    result.fold(
          (failure) => emit(AuctionDetailError(failure.message)),
          (auction) {
        emit(AuctionDetailLoaded(auction: auction));
        add(SubscribeToAuction(auctionId: event.auctionId));
      },
    );
  }

  void _onSubscribeToAuction(
      SubscribeToAuction event,
      Emitter<AuctionDetailState> emit,
      ) {
    _auctionSubscription?.cancel();
    _auctionSubscription = watchAuction(event.auctionId).listen(
          (auction) => add(AuctionUpdated(auction: auction)),
    );
  }

  void _onAuctionUpdated(
      AuctionUpdated event,
      Emitter<AuctionDetailState> emit,
      ) {
    emit(AuctionDetailLoaded(auction: event.auction));
  }

  Future<void> _onPlaceBidRequested(
      PlaceBidRequested event,
      Emitter<AuctionDetailState> emit,
      ) async {
    if (state is AuctionDetailLoaded) {
      final current = (state as AuctionDetailLoaded);
      emit(BidPlacing(auction: current.auction));

      final result = await placeBid(PlaceBidParams(
        auctionId: event.auctionId,
        bidAmount: event.bidAmount,
      ));

      result.fold(
            (failure) => emit(BidFailed(
          auction: current.auction,
          error: failure.message,
        )),
            (_) => emit(BidSuccess(auction: current.auction)),
      );
    }
  }

  @override
  Future<void> close() {
    _auctionSubscription?.cancel();
    return super.close();
  }
}