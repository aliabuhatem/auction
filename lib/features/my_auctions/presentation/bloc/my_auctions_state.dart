part of 'my_auctions_bloc.dart';

abstract class MyAuctionsState extends Equatable {
  const MyAuctionsState();
  @override
  List<Object?> get props => [];
}

class MyAuctionsInitial extends MyAuctionsState {}

class MyAuctionsLoading extends MyAuctionsState {}

class MyAuctionsLoaded extends MyAuctionsState {
  final List<AuctionEntity> activeBids;
  final List<AuctionEntity> wonAuctions;
  final List<AuctionEntity> pendingPayments;

  const MyAuctionsLoaded({
    required this.activeBids,
    required this.wonAuctions,
    required this.pendingPayments,
  });

  @override
  List<Object?> get props => [activeBids, wonAuctions, pendingPayments];
}

class MyAuctionsError extends MyAuctionsState {
  final String message;
  const MyAuctionsError(this.message);
  @override
  List<Object?> get props => [message];
}
