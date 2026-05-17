import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_notifications_bloc.dart';
import '../widgets/admin_shell.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../../data/datasources/admin_notifications_datasource.dart';
import '../../../../core/constants/app_colors.dart';

// ── Page ──────────────────────────────────────────────────────────────────────

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          AdminNotificationsBloc(ctx.read<AdminNotificationsDatasource>())
            ..add(const LoadAdminNotifications()),
      child: const AdminShell(selectedIndex: 7, child: _NotificationsBody()),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminNotificationsBloc, AdminNotificationsState>(
      listenWhen: (_, s) =>
          s is AdminNotificationsError ||
          s is AdminNotificationsLoaded && s.justSent,
      listener: (context, state) {
        if (state is AdminNotificationsError && state.notifications.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        }
        if (state is AdminNotificationsLoaded && state.justSent) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Melding ingepland'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is AdminNotificationsInitial ||
            state is AdminNotificationsLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed));
        }

        List<AdminNotificationEntity> notifications = const [];
        bool isSending = false;

        if (state is AdminNotificationsLoaded) {
          notifications = state.notifications;
        } else if (state is AdminNotificationsSending) {
          notifications = state.notifications;
          isSending = true;
        } else if (state is AdminNotificationsError) {
          notifications = state.notifications;
        }

        return _NotificationsContent(
          notifications: notifications,
          isSending: isSending,
        );
      },
    );
  }
}

// ── Content ───────────────────────────────────────────────────────────────────

class _NotificationsContent extends StatelessWidget {
  final List<AdminNotificationEntity> notifications;
  final bool isSending;
  const _NotificationsContent({
    required this.notifications,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meldingen',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: Color(0xFF1A1D27))),
                  SizedBox(height: 2),
                  Text('Stuur push-meldingen naar gebruikers',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B9CB6))),
                ]),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => context
                  .read<AdminNotificationsBloc>()
                  .add(const LoadAdminNotifications()),
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Vernieuwen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF5A6478),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Two-column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compose form
              Expanded(
                  flex: 5,
                  child: _ComposeCard(isSending: isSending)),
              const SizedBox(width: 16),
              // History
              Expanded(
                  flex: 7,
                  child: _HistoryCard(notifications: notifications)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Compose card ──────────────────────────────────────────────────────────────

class _ComposeCard extends StatefulWidget {
  final bool isSending;
  const _ComposeCard({this.isSending = false});

  @override
  State<_ComposeCard> createState() => _ComposeCardState();
}

class _ComposeCardState extends State<_ComposeCard> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  bool _toAll      = true;
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AdminNotificationsBloc>().add(SendAdminNotification(
      title: _titleCtrl.text.trim(),
      body:  _bodyCtrl.text.trim(),
      toAll: _toAll,
    ));
    _titleCtrl.clear();
    _bodyCtrl.clear();
    setState(() => _toAll = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.send_rounded,
                  size: 18, color: AppColors.primaryRed),
              SizedBox(width: 8),
              Text('Nieuwe melding',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1D27))),
            ]),
            const SizedBox(height: 20),

            // Title
            const _Label('Titel'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              maxLength: 65,
              style: const TextStyle(fontSize: 13),
              decoration: _inputDecoration('Bijv. Nieuwe veiling beschikbaar!'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Titel is vereist' : null,
            ),
            const SizedBox(height: 14),

            // Body
            const _Label('Bericht'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _bodyCtrl,
              maxLines: 4,
              maxLength: 200,
              style: const TextStyle(fontSize: 13),
              decoration:
                  _inputDecoration('Schrijf je melding hier…'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Bericht is vereist' : null,
            ),
            const SizedBox(height: 16),

            // Target
            const _Label('Doelgroep'),
            const SizedBox(height: 8),
            Row(children: [
              _TargetOption(
                label:    'Alle gebruikers',
                subtitle: 'Broadcast naar iedereen',
                icon:     Icons.people_rounded,
                selected: _toAll,
                onTap:    () => setState(() => _toAll = true),
              ),
              const SizedBox(width: 8),
              _TargetOption(
                label:    'Specifieke gebruiker',
                subtitle: 'Stuur naar één persoon',
                icon:     Icons.person_rounded,
                selected: !_toAll,
                onTap:    () => setState(() => _toAll = false),
              ),
            ]),
            const SizedBox(height: 20),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.isSending ? null : _send,
                icon: widget.isSending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 16),
                label: Text(widget.isSending ? 'Bezig met verzenden…' : 'Stuur melding'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),

            // Info note
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Meldingen worden ingepland en verwerkt door de '
                      'Firebase Cloud Messaging service. De status wordt '
                      'bijgewerkt na verwerking.',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Color(0xFFB0B8C8), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFAFAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: AppColors.primaryRed, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        counterStyle: const TextStyle(fontSize: 10, color: Color(0xFF8B9CB6)),
      );
}

// ── Target option ─────────────────────────────────────────────────────────────

class _TargetOption extends StatelessWidget {
  final String     label;
  final String     subtitle;
  final IconData   icon;
  final bool       selected;
  final VoidCallback onTap;

  const _TargetOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = selected ? AppColors.primaryRed : const Color(0xFF8B9CB6);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryRed.withValues(alpha: 0.06)
                : const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primaryRed.withValues(alpha: 0.3)
                  : const Color(0xFFE8EAF0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: c),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: c)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8B9CB6))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── History card ──────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final List<AdminNotificationEntity> notifications;
  const _HistoryCard({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              const Icon(Icons.history_rounded,
                  size: 16, color: Color(0xFF8B9CB6)),
              const SizedBox(width: 6),
              Text('${notifications.length} meldingen',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1A1D27))),
            ]),
          ),
          const SizedBox(height: 8),
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.notifications_none_rounded,
                        size: 48, color: Color(0xFFCBD5E1)),
                    SizedBox(height: 12),
                    Text('Nog geen meldingen verzonden',
                        style:
                            TextStyle(color: Color(0xFF8B9CB6), fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ...notifications.map((n) => _NotificationTile(notification: n)),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AdminNotificationEntity notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final dtFmt = DateFormat('dd MMM yyyy, HH:mm', 'nl_NL');
    final n     = notification;

    Color statusColor() => switch (n.status) {
          'sent'      => const Color(0xFF10B981),
          'failed'    => const Color(0xFFEF4444),
          'scheduled' => const Color(0xFFF59E0B),
          _           => const Color(0xFF8B9CB6),
        };

    String statusLabel() => switch (n.status) {
          'sent'      => 'Verzonden',
          'failed'    => 'Mislukt',
          'scheduled' => 'Ingepland',
          _           => n.status,
        };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF8F8FA))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (n.isSentToAll
                      ? const Color(0xFF3B82F6)
                      : AppColors.primaryRed)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              n.isSentToAll
                  ? Icons.campaign_rounded
                  : Icons.person_rounded,
              size: 18,
              color: n.isSentToAll
                  ? const Color(0xFF3B82F6)
                  : AppColors.primaryRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(n.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1A1D27)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: statusColor().withValues(alpha: 0.25)),
                  ),
                  child: Text(statusLabel(),
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor())),
                ),
              ]),
              const SizedBox(height: 3),
              Text(n.body,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF5A6478)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.schedule_rounded,
                    size: 11, color: Color(0xFF8B9CB6)),
                const SizedBox(width: 3),
                Text(dtFmt.format(n.createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF8B9CB6))),
                const SizedBox(width: 10),
                Icon(
                  n.isSentToAll
                      ? Icons.people_rounded
                      : Icons.person_rounded,
                  size: 11,
                  color: const Color(0xFF8B9CB6),
                ),
                const SizedBox(width: 3),
                Text(
                  n.isSentToAll ? 'Alle gebruikers' : 'Specifieke gebruiker',
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8B9CB6)),
                ),
                if (n.sentCount > 0) ...[
                  const SizedBox(width: 10),
                  Text('${n.sentCount}×',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981))),
                ],
              ]),
            ],
          )),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: Color(0xFF8B9CB6)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete',
                  child: Text('Verwijderen',
                      style: TextStyle(color: Colors.red, fontSize: 13))),
            ],
            onSelected: (v) {
              if (v == 'delete') {
                _confirmDelete(context, n.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Melding verwijderen?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
            'Weet je zeker dat je deze melding wilt verwijderen?',
            style: TextStyle(fontSize: 13, color: Color(0xFF5A6478))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<AdminNotificationsBloc>()
                  .add(DeleteAdminNotification(id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B9CB6),
          letterSpacing: 0.5));
}
