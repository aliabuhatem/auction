import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../../../core/constants/app_colors.dart';

/// Simple bar chart using Canvas — no extra package needed.
class AdminChart extends StatelessWidget {
  final String           title;
  final List<ChartPoint> points;

  const AdminChart({super.key, required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1D27))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('7 dagen', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: AppColors.primaryRed)),
            ),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: points.isEmpty
                ? const Center(child: Text('Geen data', style: TextStyle(color: Colors.grey)))
                : CustomPaint(
                    size: Size.infinite,
                    painter: _BarChartPainter(points: points, color: AppColors.primaryRed),
                  ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color            color;
  const _BarChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxVal    = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final barWidth  = (size.width / points.length) * 0.5;
    final spacing   = size.width / points.length;
    const textStyle = TextStyle(color: Color(0xFF8B9CB6), fontSize: 10);

    final barPaint = Paint()
      ..color    = color
      ..style    = PaintingStyle.fill;

    final bgPaint = Paint()
      ..color    = color.withOpacity(0.07)
      ..style    = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final x          = spacing * i + spacing / 2;
      final normalised = maxVal > 0 ? points[i].value / maxVal : 0.0;
      final barHeight  = normalised * (size.height - 24);

      // Background bar
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, 0, barWidth, size.height - 24),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, bgPaint);

      // Filled bar
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - barWidth / 2, size.height - 24 - barHeight, barWidth, barHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(barRect, barPaint);

      // Label
      final tp = TextPainter(
        text: TextSpan(text: points[i].label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.points != points;
}
