part of 'auction_list_bloc.dart';

abstract class AuctionListEvent extends Equatable {
  const AuctionListEvent(); // ← add this const constructor
  @override List<Object?> get props => [];
}
class LoadAuctions extends AuctionListEvent {}
class LoadMoreAuctions extends AuctionListEvent {}
class RefreshAuctions extends AuctionListEvent {}
class FilterByCategory extends AuctionListEvent {
  final AuctionCategory? category;
  const FilterByCategory({this.category});
  @override List<Object?> get props => [category];
}
class SearchAuctions extends AuctionListEvent {
  final String query;
  const SearchAuctions(this.query);
  @override List<Object> get props => [query];
}
class AuctionListStreamUpdated extends AuctionListEvent {
  final List<AuctionEntity> auctions;
  const AuctionListStreamUpdated(this.auctions);
  @override List<Object> get props => [auctions];
}
class AuctionListStreamFailed extends AuctionListEvent {
  final String error;
  const AuctionListStreamFailed(this.error);
  @override List<Object> get props => [error];
}
