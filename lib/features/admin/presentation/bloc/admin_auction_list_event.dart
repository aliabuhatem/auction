part of 'admin_auction_list_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AdminAuctionListEvent extends Equatable {
  const AdminAuctionListEvent();
  @override List<Object?> get props => [];
}

class LoadAdminAuctions extends AdminAuctionListEvent {}

class FilterAdminAuctions extends AdminAuctionListEvent {
  final AuctionStatus?   status;
  final AuctionCategory? category;
  final String?          search;
  const FilterAdminAuctions({this.status, this.category, this.search});
  @override List<Object?> get props => [status, category, search];
}

class DeleteAdminAuction extends AdminAuctionListEvent {
  final String id;
  const DeleteAdminAuction(this.id);
  @override List<Object> get props => [id];
}

class ChangeAuctionStatus extends AdminAuctionListEvent {
  final String        id;
  final AuctionStatus status;
  const ChangeAuctionStatus(this.id, this.status);
  @override List<Object> get props => [id, status];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AdminAuctionListState extends Equatable {
  const AdminAuctionListState();
  @override List<Object?> get props => [];
}

class AdminAuctionListInitial extends AdminAuctionListState {}
class AdminAuctionListLoading extends AdminAuctionListState {}

class AdminAuctionListLoaded extends AdminAuctionListState {
  final List<AdminAuctionEntity> auctions;
  final AuctionStatus?           statusFilter;
  final AuctionCategory?         categoryFilter;
  final String                   search;

  const AdminAuctionListLoaded({
    required this.auctions,
    this.statusFilter,
    this.categoryFilter,
    this.search = '',
  });
  @override List<Object?> get props => [auctions, statusFilter, categoryFilter, search];
}

class AdminAuctionListError extends AdminAuctionListState {
  final String message;
  const AdminAuctionListError(this.message);
  @override List<Object> get props => [message];
}
