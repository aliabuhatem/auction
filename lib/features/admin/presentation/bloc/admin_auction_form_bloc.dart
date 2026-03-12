import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_auction_datasource.dart';

part 'admin_auction_form_event.dart';

class AdminAuctionFormBloc
    extends Bloc<AdminAuctionFormEvent, AdminAuctionFormState> {
  final AdminAuctionDatasource _ds;

  AdminAuctionFormBloc(this._ds) : super(AdminAuctionFormInitial()) {
    on<SubmitAuctionForm>(_onSubmit);
    on<UploadAuctionImage>(_onUpload);
    on<RemoveAuctionImage>(_onRemoveImage);
  }

  // pending images before auction is saved
  final List<String> _uploadedUrls = [];

  Future<void> _onUpload(
      UploadAuctionImage event, Emitter<AdminAuctionFormState> emit) async {
    emit(AuctionImageUploading());
    try {
      // Use a temp ID for pre-upload
      final url = await _ds.uploadAuctionImage(
        auctionId: event.tempId,
        bytes:     event.bytes,
        fileName:  event.fileName,
      );
      _uploadedUrls.add(url);
      emit(AuctionImageUploaded(url));
    } catch (e) {
      emit(AdminAuctionFormError('Afbeelding uploaden mislukt: $e'));
    }
  }

  Future<void> _onRemoveImage(
      RemoveAuctionImage event, Emitter<AdminAuctionFormState> emit) async {
    _uploadedUrls.remove(event.url);
    await _ds.deleteImage(event.url);
    emit(AuctionImageRemoved(event.url));
  }

  Future<void> _onSubmit(
      SubmitAuctionForm event, Emitter<AdminAuctionFormState> emit) async {
    emit(AdminAuctionFormSaving());
    try {
      if (event.isEdit && event.auctionId != null) {
        // ── Edit ──────────────────────────────────────────────────────────
        await _ds.updateAuction(event.auctionId!, {
          'title':       event.title,
          'description': event.description,
          'category':    event.category.firestoreValue,
          'retailValue': event.retailValue,
          'startingBid': event.startingBid,
          'status':      event.status.firestoreValue,
          'images':      event.images,
          'location':    event.location,
          'startAt':     event.startAt.toIso8601String(),
          'endsAt':      event.endsAt.toIso8601String(),
        });
        final updated = await _ds.getAuction(event.auctionId!);
        emit(AdminAuctionFormSaved(updated, isEdit: true));
      } else {
        // ── Create ────────────────────────────────────────────────────────
        final auction = await _ds.createAuction(
          title:       event.title,
          description: event.description,
          category:    event.category,
          retailValue: event.retailValue,
          startingBid: event.startingBid,
          status:      event.status,
          startAt:     event.startAt,
          endsAt:      event.endsAt,
          location:    event.location,
          imageUrls:   event.images,
        );
        emit(AdminAuctionFormSaved(auction, isEdit: false));
      }
    } catch (e) {
      emit(AdminAuctionFormError(e.toString()));
    }
  }
}
