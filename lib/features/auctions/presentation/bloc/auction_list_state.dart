part of 'auction_list_bloc.dart';

abstract class AuctionListState extends Equatable {
  const AuctionListState(); // ← add this
  @override List<Object?> get props => [];
}

class AuctionListInitial extends AuctionListState {}
class AuctionListLoading extends AuctionListState {}
class AuctionListLoaded extends AuctionListState {
  final List<AuctionEntity> auctions;
  final List<AuctionEntity> endingSoonAuctions;
  final List<AuctionEntity> featuredAuctions;
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final AuctionCategory? selectedCategory;

  const AuctionListLoaded({
    required this.auctions,
    this.endingSoonAuctions = const [],
    this.featuredAuctions = const [],
    required this.hasMore,
    this.isLoadingMore = false,
    required this.currentPage,
    this.selectedCategory,
  });

  AuctionListLoaded copyWith({bool? isLoadingMore}) => AuctionListLoaded(
    auctions: auctions, endingSoonAuctions: endingSoonAuctions,
    featuredAuctions: featuredAuctions, hasMore: hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    currentPage: currentPage, selectedCategory: selectedCategory,
  );
  @override List<Object?> get props => [auctions, hasMore, isLoadingMore, currentPage, selectedCategory];
}
class AuctionListError extends AuctionListState {
  final String message;
  const AuctionListError(this.message);
  @override List<Object> get props => [message];
}
