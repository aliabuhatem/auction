import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable glassmorphism surface.
///
/// background: rgba(255,255,255,0.05) · backdrop blur(12) ·
/// border: 1px rgba(255,255,255,0.1) · radius 16 · soft deep shadow.
///
/// In light (ivory) mode it degrades gracefully to a solid card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double blur;
  final Color? fill;
  final Color? borderColor;
  final bool goldBorder;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppColors.glassRadius,
    this.blur = AppColors.glassBlur,
    this.fill,
    this.borderColor,
    this.goldBorder = false,
    this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = borderColor ??
        (goldBorder
            ? AppColors.goldBorder
            : (isDark ? AppColors.glassBorder : AppColors.ivoryBorder));
    final surface = fill ??
        (isDark ? AppColors.glassFill : AppColors.ivorySurface);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: shadow ?? AppColors.glassShadow,
      ),
      child: child,
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: isDark
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            )
          : content,
    );

    if (onTap == null) return clipped;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: clipped);
  }
}

/// A small frosted icon button (back / share / favourite) used over imagery
/// and in app bars. Dark translucent glass with a hairline border.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final double size;
  const GlassIconButton({
    super.key,
    required this.icon,
    this.iconColor,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }
}
