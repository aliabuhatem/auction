// lib/features/profile/presentation/pages/account_settings_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/app_router.dart';
import '../../../../core/constants/app_colors.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool  _saving    = false;
  bool  _loading   = true;

  // Notification toggles (stored in users/{uid})
  bool _notifBids    = true;
  bool _notifWon     = true;
  bool _notifAlarms  = true;
  bool _notifOffers  = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = _user?.uid;
    if (uid == null) { setState(() => _loading = false); return; }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameCtrl.text  = _user?.displayName ?? '';
      _phoneCtrl.text = data['phoneNumber'] as String? ?? '';
      final notif     = data['notificationPrefs'] as Map<String, dynamic>? ?? {};
      setState(() {
        _notifBids   = notif['bids']   as bool? ?? true;
        _notifWon    = notif['won']    as bool? ?? true;
        _notifAlarms = notif['alarms'] as bool? ?? true;
        _notifOffers = notif['offers'] as bool? ?? false;
        _loading     = false;
      });
    } else {
      _nameCtrl.text = _user?.displayName ?? '';
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final uid  = _user!.uid;
      final name = _nameCtrl.text.trim();

      // Update Firebase Auth display name.
      await _user!.updateDisplayName(name);

      // Update Firestore user document.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'displayName':   name,
        'phoneNumber':   _phoneCtrl.text.trim(),
        'notificationPrefs': {
          'bids':   _notifBids,
          'won':    _notifWon,
          'alarms': _notifAlarms,
          'offers': _notifOffers,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instellingen opgeslagen!')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('requires-recent-login')
            ? 'Log opnieuw in om je naam te wijzigen.'
            : 'Opslaan mislukt. Probeer het opnieuw.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _user?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resetlink verzonden naar $email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: ${e.toString()}'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    // First confirm dialog
    final step1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Account verwijderen?'),
        content: const Text(
            'Weet je zeker dat je je account wil verwijderen? Dit kan niet ongedaan worden gemaakt.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verwijderen',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Second confirm — type DELETE
    String typed = '';
    final step2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Bevestig verwijdering'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Typ DELETE om te bevestigen:'),
            const SizedBox(height: 12),
            TextField(
              autofocus:   true,
              decoration:  const InputDecoration(hintText: 'DELETE'),
              onChanged:   (v) => typed = v,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(typed == 'DELETE'),
            child: const Text('Definitief verwijderen',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (step2 != true || !mounted) return;

    try {
      final uid = _user!.uid;
      // Delete Firestore user document.
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // Delete Firebase Auth account (requires recent login).
      await _user!.delete();
      if (mounted) context.go(AppRoutes.login);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Log opnieuw in om je account te verwijderen.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Fout: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn gegevens'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Opslaan',
                    style: TextStyle(
                        color:      AppColors.primaryRed,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Personal info ──────────────────────────────────────────
                  const _Section(title: 'Persoonlijke gegevens'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller:  _nameCtrl,
                    decoration:  const InputDecoration(
                      labelText: 'Naam',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Naam is verplicht' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller:     _phoneCtrl,
                    decoration:     const InputDecoration(
                      labelText: 'Telefoonnummer',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType:   TextInputType.phone,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),

                  // Email (read-only)
                  TextFormField(
                    initialValue: _user?.email ?? '',
                    readOnly:     true,
                    decoration:   InputDecoration(
                      labelText:  'E-mailadres',
                      prefixIcon: const Icon(Icons.email_outlined),
                      fillColor:  Colors.grey.shade100,
                      filled:     true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Security ───────────────────────────────────────────────
                  const _Section(title: 'Beveiliging'),
                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline),
                    title:   const Text('Wachtwoord wijzigen'),
                    subtitle: const Text('Ontvang een resetlink per e-mail'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:   _sendPasswordReset,
                  ),

                  const Divider(),
                  const SizedBox(height: 8),

                  // ── Notification preferences ──────────────────────────────
                  const _Section(title: 'Meldingsvoorkeuren'),
                  const SizedBox(height: 12),

                  _NotifSwitch(
                    icon:     Icons.gavel,
                    label:    'Overboden',
                    subtitle: 'Ontvang een melding als je overboden wordt',
                    value:    _notifBids,
                    onChanged: (v) => setState(() => _notifBids = v),
                  ),
                  _NotifSwitch(
                    icon:     Icons.emoji_events_outlined,
                    label:    'Gewonnen',
                    subtitle: 'Melding als je een veiling wint',
                    value:    _notifWon,
                    onChanged: (v) => setState(() => _notifWon = v),
                  ),
                  _NotifSwitch(
                    icon:     Icons.alarm_outlined,
                    label:    'Alarms',
                    subtitle: 'Veilingsalarmen die je hebt ingesteld',
                    value:    _notifAlarms,
                    onChanged: (v) => setState(() => _notifAlarms = v),
                  ),
                  _NotifSwitch(
                    icon:     Icons.local_offer_outlined,
                    label:    'Aanbiedingen',
                    subtitle: 'Nieuwe veilingen en promoties',
                    value:    _notifOffers,
                    onChanged: (v) => setState(() => _notifOffers = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Danger zone ────────────────────────────────────────────
                  const _Section(title: 'Gevaarlijk gebied'),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    icon:  const Icon(Icons.delete_forever_rounded,
                        color: AppColors.error),
                    label: const Text('Account verwijderen',
                        style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side:  const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color:       AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _NotifSwitch extends StatelessWidget {
  final IconData    icon;
  final String      label;
  final String      subtitle;
  final bool        value;
  final ValueChanged<bool> onChanged;
  const _NotifSwitch({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary:      Icon(icon, color: AppColors.textSecondary),
      title:          Text(label),
      subtitle:       Text(subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      value:          value,
      activeThumbColor:    AppColors.primaryRed,
      onChanged:      onChanged,
    );
  }
}
