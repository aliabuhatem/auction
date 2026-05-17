import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_bid_entity.dart';
import '../../data/datasources/admin_bids_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminBidsEvent extends Equatable {
  const AdminBidsEvent();
  @override List<Object?> get props => [];
}

class LoadAdminBids extends AdminBidsEvent { const LoadAdminBids(); }

class FilterAdminBids extends AdminBidsEvent {
  final String? search;
  final String? auctionId;
  const FilterAdminBids({this.search, this.auctionId});
  @override List<Object?> get props => [search, auctionId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminBidsState extends Equatable {
  const AdminBidsState();
  @override List<Object?> get props => [];
}

class AdminBidsInitial extends AdminBidsState {}
class AdminBidsLoading extends AdminBidsState {}

class AdminBidsError extends AdminBidsState {
  final String message;
  const AdminBidsError(this.message);
  @override List<Object?> get props => [message];
}

class AdminBidsLoaded extends AdminBidsState {
  final List<AdminBidEntity> bids;
  final BidStatsEntity       stats;
  final String               search;
  final String?              auctionFilter;

  const AdminBidsLoaded({
    required this.bids,
    required this.stats,
    this.search        = '',
    this.auctionFilter,
  });

  @override List<Object?> get props => [bids, stats, search, auctionFilter];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AdminBidsBloc extends Bloc<AdminBidsEvent, AdminBidsState> {
  final AdminBidsDatasource _ds;
  String? _search;
  String? _auctionId;

  AdminBidsBloc(this._ds) : super(AdminBidsInitial()) {
    on<LoadAdminBids>  (_onLoad);
    on<FilterAdminBids>(_onFilter);
  }

  Future<void> _onLoad(
      LoadAdminBids e, Emitter<AdminBidsState> emit) async {
    emit(AdminBidsLoading());
    try {
      final results = await Future.wait([
        _ds.getBids(search: _search, auctionId: _auctionId),
        _ds.getBidStats(),
      ]);
      emit(AdminBidsLoaded(
        bids:          results[0] as List<AdminBidEntity>,
        stats:         results[1] as BidStatsEntity,
        search:        _search    ?? '',
        auctionFilter: _auctionId,
      ));
    } catch (e) {
      emit(AdminBidsError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onFilter(FilterAdminBids e, Emitter<AdminBidsState> emit) {
    _search    = e.search?.isEmpty == true ? null : e.search;
    _auctionId = e.auctionId;
    add(const LoadAdminBids());
  }
}
