import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_auth_bloc.dart';
import '../widgets/admin_shell.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../../../core/constants/app_colors.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminShell(selectedIndex: 8, child: _SettingsBody());
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthBloc>().state;
    final user = auth is AdminAuthenticated ? auth.user : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Instellingen', style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 22,
                  color: Color(0xFF1A1D27))),
              SizedBox(height: 2),
              Text('Systeem- en app-instellingen beheren',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
            ]),
          ]),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                flex: 3,
                child: Column(children: [
                  _AppSettingsCard(),
                  const SizedBox(height: 16),
                  _BannersCard(),
                  const SizedBox(height: 16),
                  _QuickLinksCard(),
                ]),
              ),
              const SizedBox(width: 16),
              // Right column
              Expanded(
                flex: 2,
                child: Column(children: [
                  _AdminProfileCard(user: user),
                  const SizedBox(height: 16),
                  _SystemInfoCard(),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── App settings card (reads/writes Firestore settings/general) ───────────────

class _AppSettingsCard extends StatefulWidget {
  @override
  State<_AppSettingsCard> createState() => _AppSettingsCardState();
}

class _AppSettingsCardState extends State<_AppSettingsCard> {
  final _db = FirebaseFirestore.instance;
  bool _loading    = true;
  bool _saving     = false;
  String? _error;

  bool   _maintenance         = false;
  bool   _allowRegistrations  = true;
  bool   _bidNotifications    = true;
  bool   _paymentReminders    = true;
  final  _appNameCtrl         = TextEditingController();
  final  _supportEmailCtrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _supportEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snap = await _db.collection('settings').doc('general').get();
      final d    = snap.data() ?? {};
      setState(() {
        _maintenance        = d['maintenanceMode']      ?? false;
        _allowRegistrations = d['allowRegistrations']   ?? true;
        _bidNotifications   = d['bidNotifications']     ?? true;
        _paymentReminders   = d['paymentReminders']     ?? true;
        _appNameCtrl.text   = d['appName']              ?? 'Vakantieveilingen';
        _supportEmailCtrl.text = d['supportEmail']      ?? '';
        _loading            = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      await _db.collection('settings').doc('general').set({
        'maintenanceMode':    _maintenance,
        'allowRegistrations': _allowRegistrations,
        'bidNotifications':   _bidNotifications,
        'paymentReminders':   _paymentReminders,
        'appName':            _appNameCtrl.text.trim(),
        'supportEmail':       _supportEmailCtrl.text.trim(),
        'updatedAt':          FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Instellingen opgeslagen'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'App-instellingen',
      icon:  Icons.tune_rounded,
      child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              ))
          : Column(children: [
              // App name
              const _Label('App naam'),
              _TextField(controller: _appNameCtrl),
              const SizedBox(height: 14),
              // Support email
              const _Label('Support e-mail'),
              _TextField(
                  controller: _supportEmailCtrl,
                  hint: 'support@vakantieveilingen.nl',
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF0F0F5)),
              const SizedBox(height: 8),
              // Toggles
              _Toggle(
                label:    'Onderhoudsmodus',
                subtitle: 'App blokkeren voor gebruikers',
                icon:     Icons.construction_rounded,
                value:    _maintenance,
                onChange: (v) => setState(() => _maintenance = v),
                alert:    _maintenance,
              ),
              _Toggle(
                label:    'Nieuwe registraties',
                subtitle: 'Nieuwe accounts toestaan',
                icon:     Icons.person_add_outlined,
                value:    _allowRegistrations,
                onChange: (v) => setState(() => _allowRegistrations = v),
              ),
              _Toggle(
                label:    'Biedings-meldingen',
                subtitle: 'Push-meldingen voor biedingen',
                icon:     Icons.notifications_outlined,
                value:    _bidNotifications,
                onChange: (v) => setState(() => _bidNotifications = v),
              ),
              _Toggle(
                label:    'Betalingsherinneringen',
                subtitle: 'Automatisch herinneringen sturen',
                icon:     Icons.email_outlined,
                value:    _paymentReminders,
                onChange: (v) => setState(() => _paymentReminders = v),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(
                    color: Colors.red, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Opslaan',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
    );
  }
}

// ── Banner management ─────────────────────────────────────────────────────────
// CRUD on the `banners` collection that powers the home-page promo carousel.
// Banners are added by image URL (Storage or external) to avoid a file upload
// dependency here; the home carousel reads `imageUrl` directly.

class _BannersCard extends StatelessWidget {
  final _db = FirebaseFirestore.instance;

  Future<void> _audit(String action, String targetId, Map<String, dynamic>? after) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    await _db.collection('audit_log').add({
      'adminId':     uid,
      'adminName':   FirebaseAuth.instance.currentUser?.email ?? 'admin',
      'action':      action,
      'targetType':  'banner',
      'targetId':    targetId,
      'after':       after,
      'performedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _toggleActive(String id, bool value) async {
    await _db.collection('banners').doc(id).update({'isActive': value});
    await _audit('banner_toggle', id, {'isActive': value});
  }

  Future<void> _delete(String id) async {
    await _db.collection('banners').doc(id).delete();
    await _audit('banner_delete', id, null);
  }

  Future<void> _openEditor(BuildContext context, {String? id, Map<String, dynamic>? existing}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _BannerEditorDialog(existing: existing),
    );
    if (result == null) return;
    if (id == null) {
      final ref = await _db.collection('banners').add({
        ...result,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _audit('banner_create', ref.id, result);
    } else {
      await _db.collection('banners').doc(id).update(result);
      await _audit('banner_update', id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Promo banners',
      icon: Icons.view_carousel_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _db.collection('banners').orderBy('sortOrder').snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryRed)),
                );
              }
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Nog geen banners. Voeg er een toe.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
                );
              }
              return Column(
                children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return _BannerRow(
                    imageUrl: d['imageUrl'] as String? ?? '',
                    title: d['title'] as String? ?? '(geen titel)',
                    linkType: d['linkType'] as String? ?? 'none',
                    isActive: d['isActive'] as bool? ?? false,
                    onToggle: (v) => _toggleActive(doc.id, v),
                    onEdit: () => _openEditor(context, id: doc.id, existing: d),
                    onDelete: () => _delete(doc.id),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Banner toevoegen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.primaryRed),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String linkType;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerRow({
    required this.imageUrl,
    required this.title,
    required this.linkType,
    required this.isActive,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 40,
              child: imageUrl.isEmpty
                  ? const ColoredBox(
                      color: Color(0xFFE8EAF0),
                      child: Icon(Icons.image_outlined,
                          size: 18, color: Color(0xFF8B9CB6)))
                  : Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFE8EAF0),
                          child: Icon(Icons.broken_image_outlined,
                              size: 18, color: Color(0xFF8B9CB6)))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1D27))),
                Text('Link: $linkType',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF8B9CB6))),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeThumbColor: AppColors.primaryRed,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: const Color(0xFF8B9CB6),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: Colors.red,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _BannerEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const _BannerEditorDialog({this.existing});

  @override
  State<_BannerEditorDialog> createState() => _BannerEditorDialogState();
}

class _BannerEditorDialogState extends State<_BannerEditorDialog> {
  late final TextEditingController _imageUrl;
  late final TextEditingController _title;
  late final TextEditingController _linkId;
  late final TextEditingController _linkUrl;
  late final TextEditingController _sortOrder;
  String _linkType = 'none';
  bool _isActive = true;

  static const _linkTypes = ['none', 'auction', 'category', 'external'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _imageUrl = TextEditingController(text: e?['imageUrl'] as String? ?? '');
    _title = TextEditingController(text: e?['title'] as String? ?? '');
    _linkId = TextEditingController(text: e?['linkId'] as String? ?? '');
    _linkUrl = TextEditingController(text: e?['linkUrl'] as String? ?? '');
    _sortOrder =
        TextEditingController(text: (e?['sortOrder'] as num?)?.toString() ?? '0');
    _linkType = e?['linkType'] as String? ?? 'none';
    _isActive = e?['isActive'] as bool? ?? true;
  }

  @override
  void dispose() {
    _imageUrl.dispose();
    _title.dispose();
    _linkId.dispose();
    _linkUrl.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  void _save() {
    if (_imageUrl.text.trim().isEmpty) return;
    Navigator.pop(context, {
      'imageUrl': _imageUrl.text.trim(),
      'title': _title.text.trim(),
      'linkType': _linkType,
      'linkId': _linkId.text.trim().isEmpty ? null : _linkId.text.trim(),
      'linkUrl': _linkUrl.text.trim().isEmpty ? null : _linkUrl.text.trim(),
      'sortOrder': int.tryParse(_sortOrder.text.trim()) ?? 0,
      'isActive': _isActive,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Banner toevoegen' : 'Banner bewerken'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Afbeelding-URL *'),
              _TextField(controller: _imageUrl, hint: 'https://…/banner.jpg'),
              const SizedBox(height: 12),
              const _Label('Titel'),
              _TextField(controller: _title, hint: 'WK-campagne'),
              const SizedBox(height: 12),
              const _Label('Link type'),
              DropdownButtonFormField<String>(
                initialValue: _linkType,
                items: _linkTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _linkType = v ?? 'none'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
                ),
              ),
              if (_linkType == 'auction' || _linkType == 'category') ...[
                const SizedBox(height: 12),
                _Label(_linkType == 'auction' ? 'Veiling-ID' : 'Categorie-slug'),
                _TextField(controller: _linkId),
              ],
              if (_linkType == 'external') ...[
                const SizedBox(height: 12),
                const _Label('Externe URL'),
                _TextField(controller: _linkUrl, hint: 'https://…'),
              ],
              const SizedBox(height: 12),
              const _Label('Volgorde'),
              _TextField(
                  controller: _sortOrder, keyboard: TextInputType.number),
              const SizedBox(height: 8),
              Row(children: [
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeThumbColor: AppColors.primaryRed,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                const Text('Actief', style: TextStyle(fontSize: 13)),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            foregroundColor: Colors.white,
          ),
          child: const Text('Opslaan'),
        ),
      ],
    );
  }
}

// ── Quick links ───────────────────────────────────────────────────────────────

class _QuickLinksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Snelle navigatie',
      icon:  Icons.grid_view_rounded,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _QuickLink(
            icon:  Icons.gavel_rounded,
            label: 'Veilingen',
            color: AppColors.primaryRed,
            onTap: () => context.go('/admin/auctions'),
          ),
          _QuickLink(
            icon:  Icons.inventory_2_rounded,
            label: 'Producten',
            color: const Color(0xFF6366F1),
            onTap: () => context.go('/admin/products'),
          ),
          _QuickLink(
            icon:  Icons.credit_card_rounded,
            label: 'Betalingen',
            color: const Color(0xFF10B981),
            onTap: () => context.go('/admin/orders'),
          ),
          _QuickLink(
            icon:  Icons.local_activity_rounded,
            label: 'Vouchers',
            color: const Color(0xFFF59E0B),
            onTap: () => context.go('/admin/vouchers'),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final Color      color;
  final VoidCallback onTap;
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ── Admin profile card ────────────────────────────────────────────────────────

class _AdminProfileCard extends StatelessWidget {
  final AdminUserEntity? user;
  const _AdminProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Admin account',
      icon:  Icons.manage_accounts_rounded,
      child: Column(children: [
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryRed.withValues(alpha: 0.12),
            child: Text(user?.initials ?? '?', style: const TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.displayName ?? '—', style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15,
                  color: Color(0xFF1A1D27))),
              const SizedBox(height: 4),
              Text(user?.email ?? '—',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF8B9CB6))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(user?.role.label ?? '—', style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
              ),
            ],
          )),
        ]),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            context.read<AdminAuthBloc>().add(AdminLogoutRequested());
            context.go('/admin/login');
          },
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: const Text('Uitloggen'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }
}

// ── System info card ──────────────────────────────────────────────────────────

class _SystemInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _Card(
      title: 'Systeem',
      icon:  Icons.info_outline_rounded,
      child: Column(children: [
        _InfoRow('Platform',  'Flutter Web'),
        _InfoRow('Backend',   'Firebase / Firestore'),
        _InfoRow('Auth',      'Firebase Auth'),
        _InfoRow('Storage',   'Firebase Storage'),
        _InfoRow('Versie',    '1.0.0'),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF8B9CB6)))),
          Expanded(child: Text(value, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D27)))),
        ]),
      );
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Widget   child;
  const _Card({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14,
              color: Color(0xFF1A1D27))),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String     label;
  final String     subtitle;
  final IconData   icon;
  final bool       value;
  final bool       alert;
  final ValueChanged<bool> onChange;

  const _Toggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChange,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18,
            color: alert ? Colors.orange : const Color(0xFF8B9CB6)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: alert ? Colors.orange : const Color(0xFF1A1D27))),
          Text(subtitle, style: const TextStyle(
              fontSize: 11, color: Color(0xFF8B9CB6))),
        ])),
        Switch(
          value: value,
          onChanged: onChange,
          activeThumbColor: alert ? Colors.orange : AppColors.primaryRed,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text, style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Color(0xFF8B9CB6), letterSpacing: 0.5)),
      );
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String?               hint;
  final TextInputType         keyboard;

  const _TextField({
    required this.controller,
    this.hint,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D27)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primaryRed, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );
}
