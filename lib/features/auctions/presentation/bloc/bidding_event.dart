part of 'bidding_bloc.dart';
abstract class BiddingEvent extends Equatable {
  const BiddingEvent(); // ← add this const constructor
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
class SubmitBid extends BiddingEvent {
  final String auctionId;
  final double amount;
  const SubmitBid({required this.auctionId, required this.amount});
  @override List<Object> get props => [auctionId, amount];
}
class ToggleWatchlist extends BiddingEvent {
  final String auctionId;
  const ToggleWatchlist(this.auctionId);
}
class SetAlarm extends BiddingEvent {
  final String auctionId;
  const SetAlarm(this.auctionId);
}
