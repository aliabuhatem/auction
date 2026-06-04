// Countdown widget

import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime  endsAt;
  final TextStyle? style;
  const CountdownWidget({super.key, required this.endsAt, this.style});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer    _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endsAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _remaining = widget.endsAt.difference(DateTime.now()));
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Text(
        AppStrings.auctionEnded(context),
        style: widget.style?.copyWith(color: AppColors.textSecondary) ??
            const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
      );
    }

    final isUrgent = _remaining.inMinutes < 10;
    final hours   = _remaining.inHours;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    String timeText;
    if (hours >= 24) {
      final days = hours ~/ 24;
      timeText =
          '$days${AppStrings.cdDay(context)} ${hours % 24}${AppStrings.cdHour(context)}';
    } else if (hours > 0) {
      timeText = '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      timeText = '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: (widget.style ?? const TextStyle()).copyWith(
        color:      isUrgent ? AppColors.primaryRed : AppColors.success,
        fontWeight: FontWeight.bold,
        fontSize:   isUrgent ? 18 : 16,
      ),
      child: Text(timeText),
    );
  }
}

class CountdownBadge extends StatelessWidget {
  final DateTime endsAt;
  const CountdownBadge({super.key, required this.endsAt});

  @override
  Widget build(BuildContext context) {
    final remaining = endsAt.difference(DateTime.now());
    final isUrgent  = remaining.inMinutes < 10;

    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        isUrgent ? AppColors.primaryRed : AppColors.deepShadow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CountdownWidget(
        endsAt: endsAt,
        style:  const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
