part of 'bidding_bloc.dart';

abstract class BiddingState extends Equatable {
  const BiddingState();
  @override List<Object?> get props => [];
}

class BiddingInitial extends BiddingState {}
class BiddingLoading extends BiddingState {}

class BiddingLoaded extends BiddingState {
  final AuctionEntity auction;
  final bool wasOutbid;
  final bool isMine;
  final bool isAlarmed;
  final double? autoBidMax;
  final bool showExtensionBanner;

  const BiddingLoaded({
    required this.auction,
    this.wasOutbid           = false,
    this.isMine              = false,
    this.isAlarmed           = false,
    this.autoBidMax,
    this.showExtensionBanner = false,
  });

  @override
  List<Object?> get props => [auction, wasOutbid, isMine, isAlarmed, autoBidMax, showExtensionBanner];
}

class BiddingPlacing extends BiddingState {
  final AuctionEntity auction;
  final bool isAutoBid;
  const BiddingPlacing({required this.auction, this.isAutoBid = false});
  @override List<Object> get props => [auction, isAutoBid];
}

class BiddingSuccess extends BiddingState {
  final AuctionEntity auction;
  final bool isAutoBid;
  final bool isMine;
  final double? autoBidMax;
  final bool isAlarmed;
  const BiddingSuccess({
    required this.auction,
    this.isAutoBid  = false,
    this.isMine     = true,
    this.autoBidMax,
    this.isAlarmed  = false,
  });
  @override List<Object?> get props => [auction, isAutoBid];
}

class BiddingFailed extends BiddingState {
  final AuctionEntity auction;
  final String error;
  const BiddingFailed({required this.auction, required this.error});
  @override List<Object> get props => [auction, error];
}

class BiddingError extends BiddingState {
  final String message;
  const BiddingError(this.message);
  @override List<Object> get props => [message];
}
