// lib/features/recent/presentation/bloc/recent_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auctions/domain/entities/auction_entity.dart';
import '../../domain/recent_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────
abstract class RecentEvent extends Equatable {
  const RecentEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecent extends RecentEvent {
  const LoadRecent();
}

class ClearRecent extends RecentEvent {
  const ClearRecent();
}

// ── States ──────────────────────────────────────────────────────────────────
abstract class RecentState extends Equatable {
  const RecentState();
  @override
  List<Object?> get props => [];
}

class RecentInitial extends RecentState {
  const RecentInitial();
}

class RecentLoading extends RecentState {
  const RecentLoading();
}

class RecentLoaded extends RecentState {
  final List<AuctionEntity> auctions;
  const RecentLoaded(this.auctions);
  @override
  List<Object?> get props => [auctions];
}

class RecentError extends RecentState {
  final String message;
  const RecentError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ────────────────────────────────────────────────────────────────────
class RecentBloc extends Bloc<RecentEvent, RecentState> {
  final RecentRepository repository;

  RecentBloc({required this.repository}) : super(const RecentInitial()) {
    on<LoadRecent>(_onLoad);
    on<ClearRecent>(_onClear);
  }

  Future<void> _onLoad(LoadRecent event, Emitter<RecentState> emit) async {
    emit(const RecentLoading());
    final result = await repository.getRecent();
    result.fold(
      (f) => emit(RecentError(f.message)),
      (list) => emit(RecentLoaded(list)),
    );
  }

  Future<void> _onClear(ClearRecent event, Emitter<RecentState> emit) async {
    final result = await repository.clear();
    result.fold(
      (f) => emit(RecentError(f.message)),
      (_) => emit(const RecentLoaded([])),
    );
  }
}
