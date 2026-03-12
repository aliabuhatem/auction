import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_product_datasource.dart';

part 'admin_product_event.dart';

class AdminProductBloc extends Bloc<AdminProductEvent, AdminProductState> {
  final AdminProductDatasource _ds;

  AdminProductBloc(this._ds) : super(AdminProductInitial()) {
    on<LoadAdminProducts>    (_onLoad);
    on<FilterAdminProducts>  (_onFilter);
    on<SaveAdminProduct>     (_onSave);
    on<DeleteAdminProduct>   (_onDelete);
    on<ToggleProductActive>  (_onToggle);
    on<UploadProductImage>   (_onUploadImage);
    on<RemoveProductImage>   (_onRemoveImage);
    on<LoadAdminCategories>  (_onLoadCategories);
    on<SaveAdminCategory>    (_onSaveCategory);
    on<ToggleCategoryActive> (_onToggleCategory);
    on<UploadCategoryBanner> (_onUploadBanner);
  }

  AuctionCategory? _categoryFilter;
  bool?            _activeFilter;
  String?          _search;

  // ── Products ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      LoadAdminProducts event, Emitter<AdminProductState> emit) async {
    emit(AdminProductLoading());
    try {
      final products = await _ds.getProducts(
        category: _categoryFilter,
        isActive: _activeFilter,
        search:   _search,
      );
      emit(AdminProductLoaded(products: products));
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onFilter(
      FilterAdminProducts event, Emitter<AdminProductState> emit) async {
    _categoryFilter = event.category;
    _activeFilter   = event.isActive;
    _search         = event.search;
    add(LoadAdminProducts());
  }

  Future<void> _onSave(
      SaveAdminProduct event, Emitter<AdminProductState> emit) async {
    emit(AdminProductSaving());
    try {
      if (event.id != null) {
        await _ds.updateProduct(event.id!, {
          'title':       event.title,
          'description': event.description,
          'category':    event.category.firestoreValue,
          'retailValue': event.retailValue,
          'isActive':    event.isActive,
          'images':      event.images,
          'location':    event.location,
        });
      } else {
        await _ds.createProduct(
          title:       event.title,
          description: event.description,
          category:    event.category,
          retailValue: event.retailValue,
          isActive:    event.isActive,
          location:    event.location,
          imageUrls:   event.images,
        );
      }
      emit(AdminProductSaved(isEdit: event.id != null));
      add(LoadAdminProducts());
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteAdminProduct event, Emitter<AdminProductState> emit) async {
    try {
      await _ds.deleteProduct(event.id);
      add(LoadAdminProducts());
    } catch (e) {
      emit(AdminProductError('Verwijderen mislukt: $e'));
    }
  }

  Future<void> _onToggle(
      ToggleProductActive event, Emitter<AdminProductState> emit) async {
    try {
      await _ds.toggleProductActive(event.id, event.isActive);
      add(LoadAdminProducts());
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onUploadImage(
      UploadProductImage event, Emitter<AdminProductState> emit) async {
    emit(ProductImageUploading());
    try {
      final url = await _ds.uploadProductImage(
        productId: event.productId,
        bytes:     event.bytes,
        fileName:  event.fileName,
      );
      emit(ProductImageUploaded(url));
    } catch (e) {
      emit(AdminProductError('Upload mislukt: $e'));
    }
  }

  Future<void> _onRemoveImage(
      RemoveProductImage event, Emitter<AdminProductState> emit) async {
    await _ds.deleteImage(event.url);
    emit(ProductImageRemoved(event.url));
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<void> _onLoadCategories(
      LoadAdminCategories event, Emitter<AdminProductState> emit) async {
    emit(AdminCategoryLoading());
    try {
      final cats = await _ds.getCategories();
      emit(AdminCategoryLoaded(cats));
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onSaveCategory(
      SaveAdminCategory event, Emitter<AdminProductState> emit) async {
    emit(AdminProductSaving());
    try {
      final fields = <String, dynamic>{
        'name':      event.name,
        'emoji':     event.emoji,
        'isActive':  event.isActive,
        'sortOrder': event.sortOrder,
      };
      if (event.bannerUrl != null) fields['bannerUrl'] = event.bannerUrl;
      await _ds.updateCategory(event.id, fields);
      emit(AdminCategorySaved());
      add(LoadAdminCategories());
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onToggleCategory(
      ToggleCategoryActive event, Emitter<AdminProductState> emit) async {
    try {
      await _ds.toggleCategoryActive(event.id, event.isActive);
      add(LoadAdminCategories());
    } catch (e) {
      emit(AdminProductError(e.toString()));
    }
  }

  Future<void> _onUploadBanner(
      UploadCategoryBanner event, Emitter<AdminProductState> emit) async {
    emit(ProductImageUploading());
    try {
      final url = await _ds.uploadCategoryBanner(
        categoryId: event.categoryId,
        bytes:      event.bytes,
        fileName:   event.fileName,
      );
      emit(CategoryBannerUploaded(url));
    } catch (e) {
      emit(AdminProductError('Banner upload mislukt: $e'));
    }
  }
}