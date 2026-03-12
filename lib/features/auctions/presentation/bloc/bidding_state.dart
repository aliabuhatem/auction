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
  const BiddingLoaded({required this.auction, this.wasOutbid = false, this.isMine = false});
  @override List<Object?> get props => [auction, wasOutbid];
}
class BiddingPlacing extends BiddingState {
  final AuctionEntity auction;
  const BiddingPlacing({required this.auction});
  @override List<Object> get props => [auction];
}
class BiddingSuccess extends BiddingState {
  final AuctionEntity auction;
  const BiddingSuccess({required this.auction});
  @override List<Object> get props => [auction];
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
