part of 'admin_product_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class AdminProductEvent extends Equatable {
  const AdminProductEvent();
  @override List<Object?> get props => [];
}

class LoadAdminProducts extends AdminProductEvent {}
class LoadAdminCategories extends AdminProductEvent {}

class FilterAdminProducts extends AdminProductEvent {
  final AuctionCategory? category;
  final bool?            isActive;
  final String?          search;
  const FilterAdminProducts({this.category, this.isActive, this.search});
  @override List<Object?> get props => [category, isActive, search];
}

class SaveAdminProduct extends AdminProductEvent {
  final String?         id;       // null = create
  final String          title;
  final String          description;
  final AuctionCategory category;
  final double          retailValue;
  final bool            isActive;
  final List<String>    images;
  final String?         location;
  const SaveAdminProduct({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.retailValue,
    required this.isActive,
    required this.images,
    this.location,
  });
  @override List<Object?> get props => [id, title, category];
}

class DeleteAdminProduct extends AdminProductEvent {
  final String id;
  const DeleteAdminProduct(this.id);
  @override List<Object> get props => [id];
}

class ToggleProductActive extends AdminProductEvent {
  final String id;
  final bool   isActive;
  const ToggleProductActive(this.id, this.isActive);
  @override List<Object> get props => [id, isActive];
}

class UploadProductImage extends AdminProductEvent {
  final String    productId;
  final Uint8List bytes;
  final String    fileName;
  const UploadProductImage({
    required this.productId,
    required this.bytes,
    required this.fileName,
  });
  @override List<Object> get props => [productId, fileName];
}

class RemoveProductImage extends AdminProductEvent {
  final String url;
  const RemoveProductImage(this.url);
  @override List<Object> get props => [url];
}

class SaveAdminCategory extends AdminProductEvent {
  final String  id;
  final String  name;
  final String  emoji;
  final bool    isActive;
  final int     sortOrder;
  final String? bannerUrl;
  const SaveAdminCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.isActive,
    required this.sortOrder,
    this.bannerUrl,
  });
  @override List<Object?> get props => [id, name, emoji];
}

class ToggleCategoryActive extends AdminProductEvent {
  final String id;
  final bool   isActive;
  const ToggleCategoryActive(this.id, this.isActive);
  @override List<Object> get props => [id, isActive];
}

class UploadCategoryBanner extends AdminProductEvent {
  final String    categoryId;
  final Uint8List bytes;
  final String    fileName;
  const UploadCategoryBanner({
    required this.categoryId,
    required this.bytes,
    required this.fileName,
  });
  @override List<Object> get props => [categoryId, fileName];
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AdminProductState extends Equatable {
  const AdminProductState();
  @override List<Object?> get props => [];
}

class AdminProductInitial    extends AdminProductState {}
class AdminProductLoading    extends AdminProductState {}
class AdminProductSaving     extends AdminProductState {}
class ProductImageUploading  extends AdminProductState {}
class AdminCategoryLoading   extends AdminProductState {}
class AdminCategorySaved     extends AdminProductState {}

class AdminProductLoaded extends AdminProductState {
  final List<AdminProductEntity> products;
  const AdminProductLoaded({required this.products});
  @override List<Object> get props => [products];
}

class AdminProductSaved extends AdminProductState {
  final bool isEdit;
  const AdminProductSaved({required this.isEdit});
  @override List<Object> get props => [isEdit];
}

class AdminCategoryLoaded extends AdminProductState {
  final List<AdminCategoryEntity> categories;
  const AdminCategoryLoaded(this.categories);
  @override List<Object> get props => [categories];
}

class ProductImageUploaded extends AdminProductState {
  final String url;
  const ProductImageUploaded(this.url);
  @override List<Object> get props => [url];
}

class ProductImageRemoved extends AdminProductState {
  final String url;
  const ProductImageRemoved(this.url);
  @override List<Object> get props => [url];
}

class CategoryBannerUploaded extends AdminProductState {
  final String url;
  const CategoryBannerUploaded(this.url);
  @override List<Object> get props => [url];
}

class AdminProductError extends AdminProductState {
  final String message;
  const AdminProductError(this.message);
  @override List<Object> get props => [message];
}