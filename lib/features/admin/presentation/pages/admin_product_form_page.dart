import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_selector/file_selector.dart';
import '../bloc/admin_product_bloc.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_product_datasource.dart';
import '../../../../core/constants/app_colors.dart';

class AdminProductFormPage extends StatefulWidget {
  final AdminProductEntity? existing;
  const AdminProductFormPage({super.key, this.existing});
  bool get isEdit => existing != null;
  @override State<AdminProductFormPage> createState() => _State();
}

class _State extends State<AdminProductFormPage> {
  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _retailCtrl  = TextEditingController();
  final _locationCtrl = TextEditingController();

  AuctionCategory _category = AuctionCategory.vacation;
  bool            _isActive = true;
  List<String>    _images   = [];
  final String    _tempId   =
      'prod_temp_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _titleCtrl.text    = p.title;
      _descCtrl.text     = p.description;
      _retailCtrl.text   = p.retailValue.toInt().toString();
      _locationCtrl.text = p.location ?? '';
      _category          = p.category;
      _isActive          = p.isActive;
      _images            = List.from(p.images);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _retailCtrl.dispose(); _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminProductBloc(context.read<AdminProductDatasource>()),
      child: Builder(builder: (ctx) {
        return BlocListener<AdminProductBloc, AdminProductState>(
          listener: (context, state) {
            if (state is ProductImageUploaded) {
              setState(() => _images.add(state.url));
            }
            if (state is ProductImageRemoved) {
              setState(() => _images.remove(state.url));
            }
            if (state is AdminProductSaved) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.isEdit
                    ? '✅ Product bijgewerkt!' : '✅ Product aangemaakt!'),
                backgroundColor: Colors.green,
              ));
              Navigator.of(context).pop();
            }
            if (state is AdminProductError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FC),
            appBar: _buildAppBar(ctx),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left — main fields
                    Expanded(
                      flex: 3,
                      child: Column(children: [
                        _card('Basisinformatie', [
                          _field('Naam *', _input(
                            ctrl: _titleCtrl,
                            hint: 'bv. Overnachting Hotel V Amsterdam',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Naam is verplicht' : null,
                          )),
                          const SizedBox(height: 14),
                          _field('Beschrijving *', _input(
                            ctrl:     _descCtrl,
                            hint:     'Beschrijf het product in detail…',
                            maxLines: 5,
                            validator: (v) =>
                            (v == null || v.trim().length < 20)
                                ? 'Minimaal 20 tekens' : null,
                          )),
                          const SizedBox(height: 14),
                          _field('Locatie', _input(
                            ctrl: _locationCtrl,
                            hint: 'bv. Amsterdam',
                          )),
                        ]),
                        const SizedBox(height: 16),
                        _card('Prijs', [
                          _field('Winkelwaarde (€) *', _input(
                            ctrl:         _retailCtrl,
                            hint:         '149',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              return (n == null || n <= 0)
                                  ? 'Voer een geldige waarde in' : null;
                            },
                          )),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 20),

                    // Right — category, active, images
                    Expanded(
                      flex: 2,
                      child: Column(children: [
                        _card('Instellingen', [
                          _field('Categorie', _dropdown<AuctionCategory>(
                            value: _category,
                            items: AuctionCategory.values.map((c) =>
                                DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.emoji} ${c.label}',
                                      style: const TextStyle(fontSize: 13)),
                                )).toList(),
                            onChanged: (v) =>
                                setState(() => _category = v!),
                          )),
                          const SizedBox(height: 14),
                          Row(children: [
                            const Text('Actief in catalogus',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: Color(0xFF5A6478))),
                            const Spacer(),
                            Switch(
                              value:       _isActive,
                              onChanged:   (v) => setState(() => _isActive = v),
                              activeColor: AppColors.primaryRed,
                            ),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        _card('Afbeeldingen', [
                          _ImagePanel(
                            images:    _images,
                            productId: widget.existing?.id ?? _tempId,
                            onRemove: (url) =>
                                ctx.read<AdminProductBloc>()
                                    .add(RemoveProductImage(url)),
                            onUpload: (bytes, name) =>
                                ctx.read<AdminProductBloc>()
                                    .add(UploadProductImage(
                                  productId: widget.existing?.id ?? _tempId,
                                  bytes:     bytes,
                                  fileName:  name,
                                )),
                          ),
                        ]),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(BuildContext ctx) => AppBar(
    backgroundColor: Colors.white, elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D27)),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(widget.isEdit ? 'Product bewerken' : 'Nieuw product',
        style: const TextStyle(fontWeight: FontWeight.w800,
            fontSize: 17, color: Color(0xFF1A1D27))),
    actions: [
      BlocBuilder<AdminProductBloc, AdminProductState>(
        builder: (context, state) {
          final saving = state is AdminProductSaving;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: saving ? null : () => _save(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: saving
                  ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text(widget.isEdit ? 'Opslaan' : 'Aanmaken',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          );
        },
      ),
    ],
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: Color(0xFFF0F0F5)),
    ),
  );

  void _save(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AdminProductBloc>().add(SaveAdminProduct(
      id:          widget.existing?.id,
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category:    _category,
      retailValue: double.tryParse(_retailCtrl.text) ?? 0,
      isActive:    _isActive,
      images:      _images,
      location:    _locationCtrl.text.trim().isEmpty
          ? null : _locationCtrl.text.trim(),
    ));
  }

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF0F0F5)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(
          fontWeight: FontWeight.w700, fontSize: 13,
          color: Color(0xFF1A1D27))),
      const SizedBox(height: 14),
      ...children,
    ]),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: Color(0xFF8B9CB6), letterSpacing: 0.5)),
      const SizedBox(height: 5),
      child,
    ],
  );

  Widget _input({
    required TextEditingController ctrl,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl, maxLines: maxLines,
    keyboardType: keyboardType, validator: validator,
    style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
      filled: true, fillColor: Colors.white,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE8EAF0)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value, items: items, onChanged: onChanged,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down,
            size: 17, color: Color(0xFF8B9CB6)),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
      ),
    ),
  );
}

// ── Image panel ───────────────────────────────────────────────────────────────

class _ImagePanel extends StatelessWidget {
  final List<String>          images;
  final String                productId;
  final void Function(String)              onRemove;
  final void Function(Uint8List, String)   onUpload;

  const _ImagePanel({
    required this.images,
    required this.productId,
    required this.onRemove,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (images.isNotEmpty)
        Wrap(
          spacing: 8, runSpacing: 8,
          children: images.map((url) => Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url, width: 76, height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      width: 76, height: 76,
                      color: const Color(0xFFF0F0F5),
                      child: const Icon(Icons.broken_image_outlined,
                          color: Color(0xFFB0B8C8)))),
            ),
            Positioned(
              top: 3, right: 3,
              child: GestureDetector(
                onTap: () => onRemove(url),
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 11, color: Colors.red),
                ),
              ),
            ),
          ])).toList(),
        ),
      const SizedBox(height: 8),
      BlocBuilder<AdminProductBloc, AdminProductState>(
        builder: (context, state) {
          final uploading = state is ProductImageUploading;
          return GestureDetector(
            onTap: uploading ? null : () => _pick(context),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color:        const Color(0xFFF8F9FC),
                border:       Border.all(color: const Color(0xFFE0E0E8)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: uploading
                  ? const Center(child: CircularProgressIndicator(
                  color: AppColors.primaryRed, strokeWidth: 2))
                  :const  Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primaryRed, size: 22),
                    SizedBox(height: 4),
                    Text('Afbeelding uploaden',
                        style: TextStyle(fontSize: 11,
                            color: Color(0xFF8B9CB6),
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          );
        },
      ),
    ]);
  }

  Future<void> _pick(BuildContext context) async {
    const typeGroup = XTypeGroup(
      label: 'Images', extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!context.mounted) return;
    onUpload(Uint8List.fromList(bytes), file.name);
  }
}