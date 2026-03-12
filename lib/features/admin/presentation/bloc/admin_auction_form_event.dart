part of 'admin_auction_form_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AdminAuctionFormEvent extends Equatable {
  const AdminAuctionFormEvent();
  @override List<Object?> get props => [];
}

class SubmitAuctionForm extends AdminAuctionFormEvent {
  final String          title;
  final String          description;
  final AuctionCategory category;
  final double          retailValue;
  final double          startingBid;
  final AuctionStatus   status;
  final DateTime        startAt;
  final DateTime        endsAt;
  final List<String>    images;
  final String?         location;
  final bool            isEdit;
  final String?         auctionId;

  const SubmitAuctionForm({
    required this.title,
    required this.description,
    required this.category,
    required this.retailValue,
    required this.startingBid,
    required this.status,
    required this.startAt,
    required this.endsAt,
    this.images    = const [],
    this.location,
    this.isEdit    = false,
    this.auctionId,
  });
  @override List<Object?> get props =>
      [title, category, status, startAt, endsAt, isEdit, auctionId];
}

class UploadAuctionImage extends AdminAuctionFormEvent {
  final Uint8List bytes;
  final String    fileName;
  final String    tempId;
  const UploadAuctionImage({
    required this.bytes, required this.fileName, required this.tempId});
  @override List<Object> get props => [fileName, tempId];
}

class RemoveAuctionImage extends AdminAuctionFormEvent {
  final String url;
  const RemoveAuctionImage(this.url);
  @override List<Object> get props => [url];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AdminAuctionFormState extends Equatable {
  const AdminAuctionFormState();
  @override List<Object?> get props => [];
}

class AdminAuctionFormInitial  extends AdminAuctionFormState {}
class AdminAuctionFormSaving   extends AdminAuctionFormState {}
class AuctionImageUploading    extends AdminAuctionFormState {}

class AuctionImageUploaded extends AdminAuctionFormState {
  final String url;
  const AuctionImageUploaded(this.url);
  @override List<Object> get props => [url];
}

class AuctionImageRemoved extends AdminAuctionFormState {
  final String url;
  const AuctionImageRemoved(this.url);
  @override List<Object> get props => [url];
}

class AdminAuctionFormSaved extends AdminAuctionFormState {
  final AdminAuctionEntity auction;
  final bool               isEdit;
  const AdminAuctionFormSaved(this.auction, {required this.isEdit});
  @override List<Object> get props => [auction, isEdit];
}

class AdminAuctionFormError extends AdminAuctionFormState {
  final String message;
  const AdminAuctionFormError(this.message);
  @override List<Object> get props => [message];
}
