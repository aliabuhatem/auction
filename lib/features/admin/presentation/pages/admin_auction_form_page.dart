import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_auction_form_bloc.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../data/datasources/admin_auction_datasource.dart';
import '../../../../core/constants/app_colors.dart';

class AdminAuctionFormPage extends StatefulWidget {
  final AdminAuctionEntity? existing;
  const AdminAuctionFormPage({super.key, this.existing});

  bool get isEdit => existing != null;

  @override
  State<AdminAuctionFormPage> createState() => _AdminAuctionFormPageState();
}

class _AdminAuctionFormPageState extends State<AdminAuctionFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl       = TextEditingController();
  final _descCtrl        = TextEditingController();
  final _retailCtrl      = TextEditingController();
  final _startingCtrl    = TextEditingController();
  final _locationCtrl    = TextEditingController();

  // State
  AuctionCategory _category    = AuctionCategory.vacation;
  AuctionStatus   _status      = AuctionStatus.draft;
  DateTime        _startAt     = DateTime.now().add(const Duration(hours: 1));
  DateTime        _endsAt      = DateTime.now().add(const Duration(days: 3));
  List<String>    _imageUrls   = [];
  final String    _tempId      = 'temp_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    if (a != null) {
      _titleCtrl.text    = a.title;
      _descCtrl.text     = a.description;
      _retailCtrl.text   = a.retailValue.toInt().toString();
      _startingCtrl.text = a.startingBid.toInt().toString();
      _locationCtrl.text = a.location ?? '';
      _category          = a.category;
      _status            = a.status;
      _startAt           = a.startAt;
      _endsAt            = a.endsAt;
      _imageUrls         = List.from(a.images);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _retailCtrl.dispose(); _startingCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAuctionFormBloc(context.read<AdminAuctionDatasource>()),
      child: Builder(builder: (ctx) {
        return BlocListener<AdminAuctionFormBloc, AdminAuctionFormState>(
          listener: (context, state) {
            if (state is AuctionImageUploaded) {
              setState(() => _imageUrls.add(state.url));
            }
            if (state is AuctionImageRemoved) {
              setState(() => _imageUrls.remove(state.url));
            }
            if (state is AdminAuctionFormSaved) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.isEdit
                    ? '✅ Veiling bijgewerkt!' : '✅ Veiling aangemaakt!'),
                backgroundColor: Colors.green,
              ));
              Navigator.of(context).pop();
            }
            if (state is AdminAuctionFormError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: _FormScaffold(
            isEdit:       widget.isEdit,
            formKey:      _formKey,
            titleCtrl:    _titleCtrl,
            descCtrl:     _descCtrl,
            retailCtrl:   _retailCtrl,
            startingCtrl: _startingCtrl,
            locationCtrl: _locationCtrl,
            category:     _category,
            status:       _status,
            startAt:      _startAt,
            endsAt:       _endsAt,
            imageUrls:    _imageUrls,
            tempId:       _tempId,
            onCategoryChanged: (v) => setState(() => _category = v!),
            onStatusChanged:   (v) => setState(() => _status   = v!),
            onStartAtChanged:  (v) => setState(() => _startAt  = v),
            onEndsAtChanged:   (v) => setState(() => _endsAt   = v),
            onSave: () => _save(ctx),
            auctionId: widget.existing?.id,
          ),
        );
      }),
    );
  }

  void _save(BuildContext ctx) {
    if (!_formKey.currentState!.validate()) return;
    ctx.read<AdminAuctionFormBloc>().add(SubmitAuctionForm(
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category:    _category,
      retailValue: double.tryParse(_retailCtrl.text)   ?? 0,
      startingBid: double.tryParse(_startingCtrl.text) ?? 0,
      status:      _status,
      startAt:     _startAt,
      endsAt:      _endsAt,
      images:      _imageUrls,
      location:    _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      isEdit:      widget.isEdit,
      auctionId:   widget.existing?.id,
    ));
  }
}

// ── Form scaffold ─────────────────────────────────────────────────────────────

class _FormScaffold extends StatelessWidget {
  final bool                    isEdit;
  final GlobalKey<FormState>    formKey;
  final TextEditingController   titleCtrl;
  final TextEditingController   descCtrl;
  final TextEditingController   retailCtrl;
  final TextEditingController   startingCtrl;
  final TextEditingController   locationCtrl;
  final AuctionCategory         category;
  final AuctionStatus           status;
  final DateTime                startAt;
  final DateTime                endsAt;
  final List<String>            imageUrls;
  final String                  tempId;
  final ValueChanged<AuctionCategory?> onCategoryChanged;
  final ValueChanged<AuctionStatus?>   onStatusChanged;
  final ValueChanged<DateTime>         onStartAtChanged;
  final ValueChanged<DateTime>         onEndsAtChanged;
  final VoidCallback                   onSave;
  final String?                        auctionId;

  const _FormScaffold({
    required this.isEdit,
    required this.formKey,
    required this.titleCtrl,
    required this.descCtrl,
    required this.retailCtrl,
    required this.startingCtrl,
    required this.locationCtrl,
    required this.category,
    required this.status,
    required this.startAt,
    required this.endsAt,
    required this.imageUrls,
    required this.tempId,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onStartAtChanged,
    required this.onEndsAtChanged,
    required this.onSave,
    this.auctionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D27)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Veiling bewerken' : 'Nieuwe veiling',
          style: const TextStyle(
            fontWeight: FontWeight.w800, fontSize: 17,
            color: Color(0xFF1A1D27)),
        ),
        actions: [
          BlocBuilder<AdminAuctionFormBloc, AdminAuctionFormState>(
            builder: (context, state) {
              final saving = state is AdminAuctionFormSaving;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed: saving ? null : onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: saving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                      : Text(isEdit ? 'Opslaan' : 'Aanmaken',
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
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left column: main fields ─────────────────────────────────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Basisinformatie',
                      children: [
                        _FormField(
                          label: 'Titel *',
                          child: _input(
                            ctrl:      titleCtrl,
                            hint:      'bv. Weekend Centerparcs De Kempervennen',
                            validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Titel is verplicht' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          label: 'Beschrijving *',
                          child: _input(
                            ctrl:      descCtrl,
                            hint:      'Beschrijf de veiling in detail…',
                            maxLines:  5,
                            validator: (v) =>
                              (v == null || v.trim().length < 20)
                                  ? 'Minimaal 20 tekens' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _FormField(
                          label: 'Locatie',
                          child: _input(ctrl: locationCtrl, hint: 'bv. Amsterdam, Noord-Holland'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _Section(
                      title: 'Prijzen',
                      children: [
                        Row(children: [
                          Expanded(child: _FormField(
                            label: 'Winkelwaarde (€) *',
                            child: _input(
                              ctrl:        retailCtrl,
                              hint:        '199',
                              keyboardType: TextInputType.number,
                              validator:   (v) {
                                final n = double.tryParse(v ?? '');
                                return (n == null || n <= 0) ? 'Voer een geldige waarde in' : null;
                              },
                            ),
                          )),
                          const SizedBox(width: 14),
                          Expanded(child: _FormField(
                            label: 'Startbod (€) *',
                            child: _input(
                              ctrl:        startingCtrl,
                              hint:        '1',
                              keyboardType: TextInputType.number,
                              validator:   (v) {
                                final n = double.tryParse(v ?? '');
                                return (n == null || n < 0) ? 'Ongeldig bedrag' : null;
                              },
                            ),
                          )),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _Section(
                      title: 'Planning',
                      children: [
                        Row(children: [
                          Expanded(child: _FormField(
                            label: 'Startdatum & tijd *',
                            child: _DateTimeField(
                              value:     startAt,
                              onChanged: onStartAtChanged,
                            ),
                          )),
                          const SizedBox(width: 14),
                          Expanded(child: _FormField(
                            label: 'Einddatum & tijd *',
                            child: _DateTimeField(
                              value:     endsAt,
                              onChanged: onEndsAtChanged,
                            ),
                          )),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // ── Right column: images, category, status ────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Status & Categorie',
                      children: [
                        _FormField(
                          label: 'Status',
                          child: _dropdown<AuctionStatus>(
                            value:    status,
                            items:    AuctionStatus.values.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label, style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: onStatusChanged,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FormField(
                          label: 'Categorie',
                          child: _dropdown<AuctionCategory>(
                            value:    category,
                            items:    AuctionCategory.values.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('${c.emoji} ${c.label}',
                                style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: onCategoryChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _Section(
                      title: 'Afbeeldingen',
                      children: [
                        _ImageUploadPanel(
                          imageUrls: imageUrls,
                          tempId:    auctionId ?? tempId,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController ctrl,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:   ctrl,
        maxLines:     maxLines,
        keyboardType: keyboardType,
        validator:    validator,
        style:        const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
        decoration: InputDecoration(
          hintText:       hint,
          hintStyle:      const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
          filled:         true,
          fillColor:      Colors.white,
          border:         OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Color(0xFFE8EAF0)),
          ),
          enabledBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Color(0xFFE8EAF0)),
          ),
          focusedBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: AppColors.primaryRed, width: 1.5),
          ),
          errorBorder:    OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: Colors.redAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          errorStyle:     const TextStyle(fontSize: 10),
        ),
      );

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:        Colors.white,
          border:       Border.all(color: const Color(0xFFE8EAF0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value:     value,
            items:     items,
            onChanged: onChanged,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 17, color: Color(0xFF8B9CB6)),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
          ),
        ),
      );
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String       title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 13,
            color: Color(0xFF1A1D27))),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: Color(0xFF8B9CB6), letterSpacing: 0.5)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

// ── Date time picker ──────────────────────────────────────────────────────────

class _DateTimeField extends StatelessWidget {
  final DateTime              value;
  final ValueChanged<DateTime> onChanged;
  const _DateTimeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy  HH:mm', 'nl_NL');
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.white,
          border:       Border.all(color: const Color(0xFFE8EAF0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF8B9CB6)),
          const SizedBox(width: 8),
          Expanded(child: Text(fmt.format(value),
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)))),
        ]),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context:     context,
      initialDate: value,
      firstDate:   DateTime.now().subtract(const Duration(days: 1)),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
      builder:     (_, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryRed),
        ),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;

    onChanged(DateTime(
      date.year, date.month, date.day, time.hour, time.minute));
  }
}

// ── Image upload panel ────────────────────────────────────────────────────────

class _ImageUploadPanel extends StatelessWidget {
  final List<String> imageUrls;
  final String       tempId;
  const _ImageUploadPanel({required this.imageUrls, required this.tempId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Existing images
        if (imageUrls.isNotEmpty)
          Wrap(
            spacing: 8, runSpacing: 8,
            children: imageUrls.map((url) => _ImageThumb(
              url:      url,
              onRemove: () => context.read<AdminAuctionFormBloc>()
                  .add(RemoveAuctionImage(url)),
            )).toList(),
          ),
        const SizedBox(height: 10),

        // Upload button
        BlocBuilder<AdminAuctionFormBloc, AdminAuctionFormState>(
          builder: (context, state) {
            final uploading = state is AuctionImageUploading;
            return GestureDetector(
              onTap: uploading ? null : () => _pickImage(context),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color:        const Color(0xFFF8F9FC),
                  border:       Border.all(
                    color:     const Color(0xFFE0E0E8),
                    style:     BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: uploading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.primaryRed, strokeWidth: 2))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.primaryRed, size: 24),
                          SizedBox(height: 4),
                          Text('Afbeelding uploaden',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6),
                              fontWeight: FontWeight.w600)),
                          Text('PNG, JPG tot 10 MB',
                            style: TextStyle(fontSize: 10, color: Color(0xFFB0B8C8))),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    const typeGroup = XTypeGroup(
      label:      'Images',
      extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!context.mounted) return;

    context.read<AdminAuctionFormBloc>().add(UploadAuctionImage(
      bytes:    Uint8List.fromList(bytes),
      fileName: file.name,
      tempId:   tempId,
    ));
  }
}

class _ImageThumb extends StatelessWidget {
  final String       url;
  final VoidCallback onRemove;
  const _ImageThumb({required this.url, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80, height: 80, color: const Color(0xFFF0F0F5),
              child: const Icon(Icons.broken_image_outlined,
                color: Color(0xFFB0B8C8)))),
        ),
        Positioned(
          top: 2, right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
