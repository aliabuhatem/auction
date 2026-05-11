part of 'my_auctions_bloc.dart';

abstract class MyAuctionsEvent extends Equatable {
  const MyAuctionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyAuctions extends MyAuctionsEvent {
  final String userId;
  const LoadMyAuctions(this.userId);
  @override
  List<Object?> get props => [userId];
}

class RefreshMyAuctions extends MyAuctionsEvent {
  final String userId;
  const RefreshMyAuctions(this.userId);
  @override
  List<Object?> get props => [userId];
}
