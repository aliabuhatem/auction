import 'package:equatable/equatable.dart';

class AdminCategoryEntity extends Equatable {
  final String  id;
  final String  name;
  final String  emoji;
  final String  slug;       // matches AuctionCategory.firestoreValue
  final bool    isActive;
  final int     productCount;
  final int     auctionCount;
  final String? bannerUrl;
  final int     sortOrder;

  const AdminCategoryEntity({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slug,
    required this.isActive,
    required this.productCount,
    required this.auctionCount,
    this.bannerUrl,
    required this.sortOrder,
  });

  AdminCategoryEntity copyWith({
    String? name,
    String? emoji,
    bool?   isActive,
    String? bannerUrl,
    int?    sortOrder,
  }) =>
      AdminCategoryEntity(
        id:           id,
        slug:         slug,
        productCount: productCount,
        auctionCount: auctionCount,
        name:         name      ?? this.name,
        emoji:        emoji     ?? this.emoji,
        isActive:     isActive  ?? this.isActive,
        bannerUrl:    bannerUrl ?? this.bannerUrl,
        sortOrder:    sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [id, slug, isActive];
}