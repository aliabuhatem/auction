import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_auction_datasource.dart';

part 'admin_auction_list_event.dart';

class AdminAuctionListBloc
    extends Bloc<AdminAuctionListEvent, AdminAuctionListState> {
  final AdminAuctionDatasource _ds;

  AdminAuctionListBloc(this._ds) : super(AdminAuctionListInitial()) {
    on<LoadAdminAuctions>(_onLoad);
    on<FilterAdminAuctions>(_onFilter);
    on<DeleteAdminAuction>(_onDelete);
    on<ChangeAuctionStatus>(_onChangeStatus);
  }

  AuctionStatus?   _statusFilter;
  AuctionCategory? _categoryFilter;
  String?          _search;

  Future<void> _onLoad(
      LoadAdminAuctions event, Emitter<AdminAuctionListState> emit) async {
    emit(AdminAuctionListLoading());
    try {
      final list = await _ds.getAuctions(
        status:      _statusFilter,
        category:    _categoryFilter,
        searchQuery: _search,
      );
      emit(AdminAuctionListLoaded(
        auctions:       list,
        statusFilter:   _statusFilter,
        categoryFilter: _categoryFilter,
        search:         _search ?? '',
      ));
    } catch (e) {
      emit(AdminAuctionListError(e.toString()));
    }
  }

  Future<void> _onFilter(
      FilterAdminAuctions event, Emitter<AdminAuctionListState> emit) async {
    _statusFilter   = event.status;
    _categoryFilter = event.category;
    _search         = event.search;
    add(LoadAdminAuctions());
  }

  Future<void> _onDelete(
      DeleteAdminAuction event, Emitter<AdminAuctionListState> emit) async {
    try {
      await _ds.deleteAuction(event.id);
      add(LoadAdminAuctions());
    } catch (e) {
      emit(AdminAuctionListError('Verwijderen mislukt: $e'));
    }
  }

  Future<void> _onChangeStatus(
      ChangeAuctionStatus event, Emitter<AdminAuctionListState> emit) async {
    try {
      await _ds.updateAuctionStatus(event.id, event.status);
      add(LoadAdminAuctions());
    } catch (e) {
      emit(AdminAuctionListError('Status wijzigen mislukt: $e'));
    }
  }
}
