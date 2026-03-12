import 'package:equatable/equatable.dart';

class VoucherEntity extends Equatable {
  final String id;
  final String code;
  final String auctionId;
  final String auctionTitle;
  final DateTime expiresAt;
  final bool isUsed;

  const VoucherEntity({required this.id, required this.code, required this.auctionId, required this.auctionTitle, required this.expiresAt, this.isUsed = false});

  String get expiresAtFormatted => '${expiresAt.day.toString().padLeft(2,'0')}-${expiresAt.month.toString().padLeft(2,'0')}-${expiresAt.year}';
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, code, isUsed];
}
