part of 'auction_detail_bloc.dart';

abstract class AuctionDetailState extends Equatable {
  const AuctionDetailState();

  @override
  List<Object?> get props => [];
}

class AuctionDetailInitial extends AuctionDetailState {}

class AuctionDetailLoading extends AuctionDetailState {}

class AuctionDetailLoaded extends AuctionDetailState {
  final AuctionEntity auction;
  final bool isRefreshing;
  final bool alarmSet;
  final bool isWatchlisted;

  const AuctionDetailLoaded({
    required this.auction,
    this.isRefreshing = false,
    this.alarmSet = false,
    this.isWatchlisted = false,
  });

  @override
  List<Object?> get props => [auction, isRefreshing, alarmSet, isWatchlisted];

  AuctionDetailLoaded copyWith({
    AuctionEntity? auction,
    bool? isRefreshing,
    bool? alarmSet,
    bool? isWatchlisted,
  }) {
    return AuctionDetailLoaded(
      auction: auction ?? this.auction,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      alarmSet: alarmSet ?? this.alarmSet,
      isWatchlisted: isWatchlisted ?? this.isWatchlisted,
    );
  }
}

class AuctionDetailError extends AuctionDetailState {
  final String message;

  const AuctionDetailError(this.message);

  @override
  List<Object> get props => [message];
}
