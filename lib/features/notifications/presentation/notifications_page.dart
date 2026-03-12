import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meldingen', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Alles lezen', style: TextStyle(color: AppColors.primaryRed))),
        ],
      ),
      body: ListView(
        children: const [
          _NotifTile(
            icon: Icons.gavel,
            color: AppColors.primaryRed,
            title: 'Je bent overboden!',
            subtitle: 'Iemand heeft hoger geboden op "Wellness weekend Veluwe"',
            time: '2 min geleden',
            isUnread: true,
          ),
          _NotifTile(
            icon: Icons.alarm,
            color: Colors.orange,
            title: 'Veiling loopt bijna af',
            subtitle: '"Citytrip Barcelona 3 dagen" eindigt over 10 minuten',
            time: '8 min geleden',
            isUnread: true,
          ),
          _NotifTile(
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: 'Gefeliciteerd! Je hebt gewonnen 🎉',
            subtitle: 'Je hebt "Spa dag voor 2" gewonnen voor €23,00',
            time: '1 uur geleden',
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  final bool isUnread;
  const _NotifTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.time, this.isUnread = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isUnread ? color.withOpacity(0.05) : null,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        isThreeLine: true,
        trailing: isUnread ? Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)) : null,
      ),
    );
  }
}
