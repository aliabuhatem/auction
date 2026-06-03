part of 'bidding_bloc.dart';

abstract class BiddingEvent extends Equatable {
  const BiddingEvent();
  @override List<Object?> get props => [];
}

class LoadAuctionForBidding extends BiddingEvent {
  final String auctionId;
  const LoadAuctionForBidding(this.auctionId);
  @override List<Object> get props => [auctionId];
}

class AuctionStreamUpdate extends BiddingEvent {
  final AuctionEntity auction;
  const AuctionStreamUpdate(this.auction);
  @override List<Object> get props => [auction];
}

class AuctionStreamFailed extends BiddingEvent {
  final String error;
  const AuctionStreamFailed(this.error);
  @override List<Object> get props => [error];
}

class SubmitBid extends BiddingEvent {
  final String auctionId;
  final double amount;
  final bool isAutoBid;
  const SubmitBid({required this.auctionId, required this.amount, this.isAutoBid = false});
  @override List<Object> get props => [auctionId, amount, isAutoBid];
}

class ToggleWatchlist extends BiddingEvent {
  final String auctionId;
  const ToggleWatchlist(this.auctionId);
  @override List<Object> get props => [auctionId];
}

class SetAlarm extends BiddingEvent {
  final String auctionId;
  const SetAlarm(this.auctionId);
  @override List<Object> get props => [auctionId];
}

class SetAutoBid extends BiddingEvent {
  final String auctionId;
  final double maxAmount;
  const SetAutoBid({required this.auctionId, required this.maxAmount});
  @override List<Object> get props => [auctionId, maxAmount];
}

class ClearAutoBid extends BiddingEvent {
  final String auctionId;
  const ClearAutoBid(this.auctionId);
  @override List<Object> get props => [auctionId];
}
