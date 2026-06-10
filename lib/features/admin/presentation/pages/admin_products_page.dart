import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_product_bloc.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_product_datasource.dart';
import '../../data/datasources/admin_auction_datasource.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/admin_shell.dart';
import 'admin_product_form_page.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminProductBloc(context.read<AdminProductDatasource>())
        ..add(LoadAdminProducts()),
      child: const AdminShell(selectedIndex: 2, child: _Body()),
    );
  }
}

// ── Body with tabs ────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Producten', style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 22,
                          color: Color(0xFF1A1D27))),
                      SizedBox(height: 2),
                      Text('Beheer producten en categorieën',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
                    ],
                  ),
                  const Spacer(),
                  _AddButton(),
                ]),
                const SizedBox(height: 16),
                const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: Color(0xFF8B9CB6),
                  indicatorColor: AppColors.primaryRed,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(text: 'Producten'),
                    Tab(text: 'Categorieën'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          // Tab views
          const Expanded(
            child: TabBarView(
              children: [
                _ProductsTab(),
                _CategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only show on Products tab
    return ElevatedButton.icon(
      onPressed: () => _openForm(context, null),
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Nieuw product'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    );
  }

  void _openForm(BuildContext context, AdminProductEntity? existing) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RepositoryProvider.value(
        value: context.read<AdminProductDatasource>(),
        child: AdminProductFormPage(existing: existing),
      ),
    )).then((_) {
      if (context.mounted) {
        context.read<AdminProductBloc>().add(LoadAdminProducts());
      }
    });
  }
}

// ── Products tab ──────────────────────────────────────────────────────────────

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();

  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  AuctionCategory? _category;
  bool?            _isActive;
  final _searchCtrl = TextEditingController();
  List<AdminProductEntity> _cachedProducts = [];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    context.read<AdminProductBloc>().add(FilterAdminProducts(
      category: _category,
      isActive: _isActive,
      search:   _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProductBloc, AdminProductState>(
      listenWhen: (_, s) => s is AdminProductError || s is AdminProductSaved,
      listener: (context, state) {
        if (state is AdminProductError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state is AdminProductSaved) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.isEdit ? 'Product bijgewerkt' : 'Product aangemaakt'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Filter bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _FilterBar(
                searchCtrl:  _searchCtrl,
                category:    _category,
                isActive:    _isActive,
                onCategory:  (v) { setState(() => _category  = v); _apply(); },
                onActive:    (v) { setState(() => _isActive  = v); _apply(); },
                onSearch:    (_) => _apply(),
                onClear: () {
                  setState(() { _category = null; _isActive = null; });
                  _searchCtrl.clear();
                  _apply();
                },
              ),
            ),
            const SizedBox(height: 16),
            // List
            Expanded(child: _buildList(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildList(BuildContext context, AdminProductState state) {
    if (state is AdminProductLoaded) {
      _cachedProducts = state.products;
    }

    if (state is AdminProductLoading || state is AdminProductInitial ||
        state is AdminProductSaving) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed));
    }
    if (state is AdminProductError) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(state.message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<AdminProductBloc>().add(LoadAdminProducts()),
            child: const Text('Opnieuw proberen'),
          ),
        ],
      ));
    }

    // Show the product list — either from the latest loaded state or the cache.
    // This prevents a blank page when the shared bloc transitions to a
    // categories-related state (AdminCategoryLoading / AdminCategoryLoaded).
    final products = (state is AdminProductLoaded)
        ? state.products
        : _cachedProducts;

    if (products.isEmpty && state is! AdminProductLoaded) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed));
    }

    if (products.isEmpty) {
      return const Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 56, color: Color(0xFFCBD5E1)),
          SizedBox(height: 12),
          Text('Geen producten gevonden',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 4),
          Text('Voeg je eerste product toe',
              style: TextStyle(color: Color(0xFF8B9CB6), fontSize: 13)),
        ],
      ));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _ProductCard(
        product: products[i],
        onEdit: () => _openForm(context, products[i]),
        onDelete: () => _confirmDelete(context, products[i]),
        onCreateAuction: () => _createAuctionFromProduct(context, products[i]),
        onToggle: (v) => context.read<AdminProductBloc>()
            .add(ToggleProductActive(products[i].id, v)),
      ),
    );
  }

  void _openForm(BuildContext context, AdminProductEntity? existing) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RepositoryProvider.value(
        value: context.read<AdminProductDatasource>(),
        child: AdminProductFormPage(existing: existing),
      ),
    )).then((_) {
      if (context.mounted) {
        context.read<AdminProductBloc>().add(LoadAdminProducts());
      }
    });
  }

  /// One-click: turns a product into a live auction (starting bid €1, runs for
  /// 7 days). The admin can fine-tune via the "Bewerken" snackbar action.
  Future<void> _createAuctionFromProduct(
      BuildContext context, AdminProductEntity product) async {
    final messenger = ScaffoldMessenger.of(context);
    final auctionDs = context.read<AdminAuctionDatasource>();
    final productDs = context.read<AdminProductDatasource>();
    final bloc      = context.read<AdminProductBloc>();
    try {
      final now = DateTime.now();
      final auction = await auctionDs.createAuction(
        title:       product.title,
        description: product.description,
        category:    product.category,
        retailValue: product.retailValue,
        startingBid: 1.0,
        status:      AuctionStatus.live,
        startAt:     now,
        endsAt:      now.add(const Duration(days: 7)),
        location:    product.location,
        imageUrls:   product.images,
      );
      // Keep the product's usage counter in sync.
      await productDs.updateProduct(product.id, {
        'usedInAuctions': product.usedInAuctions + 1,
      });
      bloc.add(LoadAdminProducts());
      messenger.showSnackBar(SnackBar(
        content: const Text('Veiling aangemaakt — verschijnt nu in de app'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Bewerken',
          textColor: Colors.white,
          onPressed: () => context.go(
            AppRoutes.adminAuctionEditPath(auction.id),
            extra: auction,
          ),
        ),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Aanmaken mislukt: $e'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _confirmDelete(BuildContext context, AdminProductEntity product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Product verwijderen?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('"${product.title}"\nDeze actie kan niet ongedaan worden gemaakt.',
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A6478))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminProductBloc>().add(DeleteAdminProduct(product.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final TextEditingController  searchCtrl;
  final AuctionCategory?       category;
  final bool?                  isActive;
  final ValueChanged<AuctionCategory?> onCategory;
  final ValueChanged<bool?>            onActive;
  final ValueChanged<String>           onSearch;
  final VoidCallback                   onClear;

  const _FilterBar({
    required this.searchCtrl,
    required this.category,
    required this.isActive,
    required this.onCategory,
    required this.onActive,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Row(children: [
        // Search
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: searchCtrl,
              onSubmitted: onSearch,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Zoek op naam…',
                hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 17, color: Color(0xFF8B9CB6)),
                filled: true,
                fillColor: const Color(0xFFF8F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Category dropdown
        _Dropdown<AuctionCategory>(
          value: category,
          hint: 'Categorie',
          items: AuctionCategory.values.map((c) => DropdownMenuItem(
            value: c,
            child: Text('${c.emoji} ${c.label}',
                style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: onCategory,
        ),
        const SizedBox(width: 10),
        // Active filter
        _Dropdown<bool>(
          value: isActive,
          hint: 'Status',
          items: const [
            DropdownMenuItem(value: true,  child: Text('Actief',    style: TextStyle(fontSize: 13))),
            DropdownMenuItem(value: false, child: Text('Inactief',  style: TextStyle(fontSize: 13))),
          ],
          onChanged: onActive,
        ),
        const SizedBox(width: 10),
        if (category != null || isActive != null || searchCtrl.text.isNotEmpty)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, size: 15),
            label: const Text('Wis', style: TextStyle(fontSize: 13)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B9CB6)),
          ),
      ]),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T?                        value;
  final String                    hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>          onChanged;

  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFF8B9CB6))),
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF8B9CB6)),
          isDense: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
        ),
      ),
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final AdminProductEntity product;
  final VoidCallback       onEdit;
  final VoidCallback       onDelete;
  final VoidCallback       onCreateAuction;
  final ValueChanged<bool> onToggle;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onCreateAuction,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Row(children: [
        // Thumbnail
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F5),
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: product.images.isNotEmpty
              ? Image.network(product.images.first, fit: BoxFit.cover,
                  cacheWidth: 120, cacheHeight: 120,
                  errorBuilder: (_, __, ___) =>
                      Center(child: Text(product.category.emoji,
                          style: const TextStyle(fontSize: 24))))
              : Center(child: Text(product.category.emoji,
                  style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: Color(0xFF1A1D27)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text('${product.category.emoji} ${product.category.label}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF5A6478))),
              ),
              const SizedBox(width: 8),
              Text('€ ${product.retailValue.toInt()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1D27))),
              if (product.location != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8B9CB6)),
                Text(product.location!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6))),
              ],
            ]),
            const SizedBox(height: 3),
            Text('${product.usedInAuctions} veiling${product.usedInAuctions != 1 ? 'en' : ''}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6))),
          ],
        )),
        // One-click: create an auction from this product
        Tooltip(
          message: 'Maak veiling van dit product',
          child: OutlinedButton.icon(
            onPressed: onCreateAuction,
            icon: const Icon(Icons.gavel_rounded, size: 15),
            label: const Text('Maak veiling'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryRed,
              side: const BorderSide(color: AppColors.primaryRed),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Active toggle
        Column(children: [
          Switch(
            value: product.isActive,
            onChanged: onToggle,
            activeThumbColor: AppColors.primaryRed,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(product.isActive ? 'Actief' : 'Inactief',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: product.isActive
                      ? const Color(0xFF10B981)
                      : const Color(0xFF8B9CB6))),
        ]),
        const SizedBox(width: 8),
        // Actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              size: 18, color: Color(0xFF8B9CB6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (_) => [
            _item('auction', Icons.gavel_rounded,   'Maak veiling'),
            _item('edit',    Icons.edit_outlined,   'Bewerken'),
            _item('delete',  Icons.delete_outline,  'Verwijderen', red: true),
          ],
          onSelected: (v) {
            if (v == 'auction') onCreateAuction();
            if (v == 'edit')    onEdit();
            if (v == 'delete')  onDelete();
          },
        ),
      ]),
    );
  }

  PopupMenuItem<String> _item(String val, IconData icon, String label,
      {bool red = false}) {
    return PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(icon, size: 15, color: red ? Colors.red : const Color(0xFF5A6478)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(
            fontSize: 13,
            color: red ? Colors.red : const Color(0xFF1A1D27))),
      ]),
    );
  }
}

// ── Categories tab ────────────────────────────────────────────────────────────

class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();
  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProductBloc>().add(LoadAdminCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminProductBloc, AdminProductState>(
      builder: (context, state) {
        if (state is AdminCategoryLoading || state is AdminProductLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed));
        }
        if (state is AdminCategoryLoaded) {
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) =>
                _CategoryCard(category: state.categories[i]),
          );
        }
        if (state is AdminProductError) {
          return Center(child: Text(state.message,
              style: const TextStyle(color: Colors.grey)));
        }
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryRed));
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AdminCategoryEntity category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Row(children: [
        // Emoji
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(category.emoji,
              style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14,
                color: Color(0xFF1A1D27))),
            const SizedBox(height: 3),
            Text('${category.productCount} producten · '
                '${category.auctionCount} live veilingen',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
          ],
        )),
        // Active toggle
        Switch(
          value: category.isActive,
          onChanged: (v) => context.read<AdminProductBloc>()
              .add(ToggleCategoryActive(category.id, v)),
          activeThumbColor: AppColors.primaryRed,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 4),
        Text(category.isActive ? 'Actief' : 'Uit',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: category.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF8B9CB6))),
      ]),
    );
  }
}
