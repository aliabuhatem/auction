import 'package:flutter/material.dart';
import '../../../../core/widgets/countdown_widget.dart';

class AuctionTimerBadge extends StatelessWidget {
  final DateTime endsAt;
  final bool large;
  const AuctionTimerBadge({super.key, required this.endsAt, this.large = false});

  @override
  Widget build(BuildContext context) {
    final remaining = endsAt.difference(DateTime.now());
    final isUrgent = remaining.inMinutes < 10;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 8, vertical: large ? 8 : 4),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFE63946) : Colors.black87,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isUrgent ? Icons.timer : Icons.access_time, color: Colors.white, size: large ? 16 : 12),
          const SizedBox(width: 4),
          CountdownWidget(
            endsAt: endsAt,
            style: TextStyle(color: Colors.white, fontSize: large ? 14 : 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
