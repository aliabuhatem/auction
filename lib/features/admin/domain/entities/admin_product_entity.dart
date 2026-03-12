import 'package:equatable/equatable.dart';
import 'admin_auction_entity.dart'; // reuse AuctionCategory from Part 2

class AdminProductEntity extends Equatable {
  final String          id;
  final String          title;
  final String          description;
  final AuctionCategory category;
  final double          retailValue;
  final List<String>    images;
  final String?         location;
  final bool            isActive;
  final int             usedInAuctions;
  final String          createdAt;
  final String          createdBy;

  const AdminProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.retailValue,
    required this.images,
    this.location,
    required this.isActive,
    required this.usedInAuctions,
    required this.createdAt,
    required this.createdBy,
  });

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  AdminProductEntity copyWith({
    String? title,
    String? description,
    AuctionCategory? category,
    double? retailValue,
    List<String>? images,
    String? location,
    bool? isActive,
  }) =>
      AdminProductEntity(
        id:             id,
        usedInAuctions: usedInAuctions,
        createdAt:      createdAt,
        createdBy:      createdBy,
        title:          title       ?? this.title,
        description:    description ?? this.description,
        category:       category    ?? this.category,
        retailValue:    retailValue ?? this.retailValue,
        images:         images      ?? this.images,
        location:       location    ?? this.location,
        isActive:       isActive    ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, title, category, isActive];
}