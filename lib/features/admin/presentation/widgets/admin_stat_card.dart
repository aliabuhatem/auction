import 'package:flutter/material.dart';

class AdminStatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  final String?  subtitle;
  final bool     alert;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.alert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert ? Colors.orange.withOpacity(0.4) : const Color(0xFFF0F0F5),
        ),
        boxShadow: [
          BoxShadow(
            color:      alert
                ? Colors.orange.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            if (alert)
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
              ),
          ]),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(
            fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF1A1D27))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF5A6478))),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(fontSize: 11, color: Color(0xFF8B9CB6))),
          ],
        ],
      ),
    );
  }
}
