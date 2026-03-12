import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// An animated category filter chip used in the horizontal scroll bar.
/// Shows an emoji + label, and animates colour when selected.
class CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Whether to show a subtle shadow when selected.
  final bool showShadow;

  const CategoryChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve:    Curves.easeInOut,
        margin:   const EdgeInsets.only(right: 8),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          boxShadow: isSelected && showShadow
              ? [
                  BoxShadow(
                    color:      AppColors.primaryRed.withOpacity(0.35),
                    blurRadius: 8,
                    offset:     const Offset(0, 3),
                  ),
                ]
              : null,
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji
            Text(emoji, style: const TextStyle(fontSize: AppDimensions.fontXL)),
            const SizedBox(width: 6),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize:   AppDimensions.fontM,
                color:      isSelected ? Colors.white : AppColors.textPrimary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact icon-only version (for tight spaces) ─────────────────────────────

class CategoryIconChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryIconChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin:  const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade100,
            shape: BoxShape.circle,
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryRed.withOpacity(0.3), blurRadius: 8)]
                : null,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}

// ── Status chip (used for auction status, voucher status, etc.) ──────────────

class StatusChip extends StatelessWidget {
  final String label;
  final Color  backgroundColor;
  final Color  textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.successLight,
    this.textColor       = AppColors.success,
    this.icon,
  });

  factory StatusChip.live() => const StatusChip(
        label:           'LIVE',
        backgroundColor: Color(0xFFFFEBEE),
        textColor:       AppColors.primaryRed,
        icon:            Icons.circle,
      );

  factory StatusChip.ending() => const StatusChip(
        label:           'Eindigt bijna',
        backgroundColor: Color(0xFFFFF3E0),
        textColor:       AppColors.warning,
        icon:            Icons.timer,
      );

  factory StatusChip.won() => const StatusChip(
        label:           'Gewonnen',
        backgroundColor: AppColors.successLight,
        textColor:       AppColors.success,
        icon:            Icons.emoji_events,
      );

  factory StatusChip.pending() => const StatusChip(
        label:           'Betalen',
        backgroundColor: Color(0xFFFFF3E0),
        textColor:       AppColors.warning,
        icon:            Icons.payment,
      );

  factory StatusChip.used() => const StatusChip(
        label:           'Gebruikt',
        backgroundColor: AppColors.backgroundGrey,
        textColor:       AppColors.textSecondary,
        icon:            Icons.check,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 11),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color:      textColor,
              fontSize:   AppDimensions.fontXS,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Savings badge (shown on auction images) ──────────────────────────────────

class SavingsBadge extends StatelessWidget {
  final double savingsPercent;
  const SavingsBadge({super.key, required this.savingsPercent});

  @override
  Widget build(BuildContext context) {
    if (savingsPercent <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        Colors.green,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        '-${savingsPercent.toStringAsFixed(0)}%',
        style: const TextStyle(
          color:      Colors.white,
          fontWeight: FontWeight.bold,
          fontSize:   AppDimensions.fontXS,
        ),
      ),
    );
  }
}
