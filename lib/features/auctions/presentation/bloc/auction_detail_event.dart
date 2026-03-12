part of 'auction_detail_bloc.dart';

abstract class AuctionDetailEvent extends Equatable {
  const AuctionDetailEvent();
  @override
  List<Object?> get props => [];
}

class LoadAuctionDetail extends AuctionDetailEvent {
  final String auctionId;
  const LoadAuctionDetail(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

class RefreshAuctionDetail extends AuctionDetailEvent {
  final String auctionId;
  const RefreshAuctionDetail(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}

class AuctionDetailStreamUpdated extends AuctionDetailEvent {
  final AuctionEntity auction;
  const AuctionDetailStreamUpdated(this.auction);
  @override
  List<Object> get props => [auction];
}

class ToggleAuctionAlarm extends AuctionDetailEvent {
  final String auctionId;
  final bool currentlySet;
  const ToggleAuctionAlarm({required this.auctionId, required this.currentlySet});
  @override
  List<Object> get props => [auctionId, currentlySet];
}

class ToggleAuctionWatchlist extends AuctionDetailEvent {
  final String auctionId;
  const ToggleAuctionWatchlist(this.auctionId);
  @override
  List<Object> get props => [auctionId];
}
