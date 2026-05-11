import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auctions/domain/entities/auction_entity.dart';
import '../../../auctions/domain/repositories/auction_repository.dart';
import '../../domain/my_auctions_repository.dart';

part 'my_auctions_event.dart';
part 'my_auctions_state.dart';

class MyAuctionsBloc extends Bloc<MyAuctionsEvent, MyAuctionsState> {
  final MyAuctionsRepository repository;
  final AuctionRepository auctionRepository;

  MyAuctionsBloc({
    required this.repository,
    required this.auctionRepository,
  }) : super(MyAuctionsInitial()) {
    on<LoadMyAuctions>(_onLoad);
    on<RefreshMyAuctions>(_onRefresh);
  }

  Future<void> _onLoad(LoadMyAuctions e, Emitter<MyAuctionsState> emit) async {
    emit(MyAuctionsLoading());
    await _fetch(e.userId, emit);
  }

  Future<void> _onRefresh(RefreshMyAuctions e, Emitter<MyAuctionsState> emit) async {
    await _fetch(e.userId, emit);
  }

  Future<void> _fetch(String userId, Emitter<MyAuctionsState> emit) async {
    final results = await Future.wait([
      repository.getActiveBids(userId),
      repository.getWonAuctions(userId),
      repository.getPendingPayments(userId),
      auctionRepository.getMyAuctions(),
    ]);

    final activeBidsResult    = results[0];
    final wonResult           = results[1];
    final pendingResult       = results[2];
    final watchlistResult     = results[3];

    // If any core fetch fails, show error
    if (activeBidsResult.isLeft() || wonResult.isLeft() || pendingResult.isLeft()) {
      final msg = activeBidsResult.fold((f) => f.message, (_) => null) ??
          wonResult.fold((f) => f.message, (_) => null) ??
          pendingResult.fold((f) => f.message, (_) => null) ??
          'Onbekende fout';
      emit(MyAuctionsError(msg));
      return;
    }

    emit(MyAuctionsLoaded(
      activeBids:      activeBidsResult.fold((_) => [], (r) => r),
      wonAuctions:     wonResult.fold((_) => [], (r) => r),
      pendingPayments: pendingResult.fold((_) => [], (r) => r),
      watchedAuctions: watchlistResult.fold((_) => [], (r) => r),
    ));
  }
}
