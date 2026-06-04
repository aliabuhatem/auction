import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return Scaffold(
        body: Center(child: Text(AppStrings.loginForNotifications(context))),
      );
    }
    final userId = auth.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notifications(context),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => _markAllRead(userId),
            child: Text(AppStrings.markAllRead(context),
                style: const TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('${AppStrings.errorPrefix(context)}${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(AppStrings.noNotifications(context),
                      style:
                          const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final type = d['type'] as String? ?? 'info';
              final isUnread = !(d['read'] as bool? ?? false);

              return _NotifTile(
                icon: _iconFor(type),
                color: _colorFor(type),
                title: d['title'] as String? ?? '',
                subtitle: d['body'] as String? ?? '',
                time: _formatTime(d['createdAt'] as Timestamp?, context),
                isUnread: isUnread,
                onTap: () {
                  if (isUnread) docs[i].reference.update({'read': true});
                  _navigateTo(context, type, d['data'] as Map<String, dynamic>? ?? {});
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateTo(BuildContext context, String type, Map<String, dynamic> data) {
    final auctionId = data['auctionId'] as String? ?? '';
    final orderId   = data['orderId']   as String? ?? '';
    switch (type) {
      case 'outbid':
      case 'alarm':
      case 'won':
        if (auctionId.isNotEmpty) context.push(AppRoutes.auctionDetailPath(auctionId));
        break;
      case 'payment':
      case 'payment_reminder':
        if (orderId.isNotEmpty) context.push(AppRoutes.paymentPath(orderId));
        break;
      case 'voucher':
        context.push(AppRoutes.tickets);
        break;
    }
  }

  Future<void> _markAllRead(String userId) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'outbid':
        return Icons.gavel;
      case 'alarm':
        return Icons.alarm;
      case 'won':
        return Icons.emoji_events;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'outbid':
        return AppColors.primaryRed;
      case 'alarm':
        return AppColors.warning;
      case 'won':
        return AppColors.accentGold;
      case 'payment':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  String _formatTime(Timestamp? ts, BuildContext context) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return AppStrings.minAgo(context, diff.inMinutes);
    if (diff.inHours < 24) return AppStrings.hourAgo(context, diff.inHours);
    return AppStrings.daysAgo(context, diff.inDays);
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  final bool isUnread;
  final VoidCallback? onTap;

  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isUnread = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isUnread ? color.withValues(alpha: 0.05) : null,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(time,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        isThreeLine: true,
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            : null,
      ),
    );
  }
}
