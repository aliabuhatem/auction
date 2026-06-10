// lib/features/info/presentation/widgets/info_scaffold.dart
//
// Shared building blocks for the static content pages (How it works, Customer
// service, About, Privacy, Terms). Matches the luxury dark-first theme using
// AppColors / AppDimensions tokens — no hardcoded colors or magic numbers.
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// A consistent scaffold for all static information pages: themed AppBar with a
/// back button + a scrollable, comfortably-padded content column.
class InfoScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;

  const InfoScaffold({
    super.key,
    required this.title,
    required this.children,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            AppDimensions.paddingL,
            AppDimensions.space3XL,
          ),
          children: children,
        ),
      ),
      bottomNavigationBar: bottom,
    );
  }
}

/// Large page lead — a headline plus a muted intro paragraph.
class InfoHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const InfoHeader({super.key, required this.title, this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: AppDimensions.avatarL,
            height: AppDimensions.avatarL,
            decoration: BoxDecoration(
              gradient: AppColors.luxuryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              boxShadow: AppColors.goldGlow(opacity: 0.30),
            ),
            child: Icon(icon, color: AppColors.textOnGold, size: AppDimensions.iconL),
          ),
          const SizedBox(height: AppDimensions.spaceL),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.fontH1,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: AppDimensions.fontXL,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spaceXL),
      ],
    );
  }
}

/// A titled prose section.
class InfoSection extends StatelessWidget {
  final String title;
  final String body;

  const InfoSection({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppDimensions.fontTitle,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            body,
            style: const TextStyle(
              fontSize: AppDimensions.fontBody,
              height: 1.7,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A numbered step card (used by How it works).
class InfoStepCard extends StatelessWidget {
  final int number;
  final String title;
  final String body;

  const InfoStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceL),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.avatarM,
            height: AppDimensions.avatarM,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: AppDimensions.fontXXL,
                fontWeight: FontWeight.w900,
                color: AppColors.textOnGold,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDimensions.fontXL,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: AppDimensions.fontBody,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An expandable FAQ row (used by Customer service).
class InfoFaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const InfoFaqItem({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Theme(
        // Strip the default ExpansionTile dividers for a clean glass card.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.gold,
          collapsedIconColor: AppColors.textSecondary,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.spaceXXS,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingM,
            0,
            AppDimensions.paddingM,
            AppDimensions.paddingM,
          ),
          title: Text(
            question,
            style: TextStyle(
              fontSize: AppDimensions.fontL,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: AppDimensions.fontBody,
                  height: 1.7,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable contact / action row used at the bottom of static pages.
class InfoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const InfoActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: AppDimensions.iconM),
            const SizedBox(width: AppDimensions.spaceL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppDimensions.fontL,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Text(
                      value!,
                      style: const TextStyle(
                        fontSize: AppDimensions.fontM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: AppDimensions.iconM,
            ),
          ],
        ),
      ),
    );
  }
}
