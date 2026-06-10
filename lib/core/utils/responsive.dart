import 'package:flutter/widgets.dart';

/// Window-size breakpoints and adaptive-layout helpers.
///
/// Follows the official Flutter guidance (flutter-build-responsive-layout):
/// base decisions on the *available window space*, never on hardware type or
/// device orientation. Use [context.widthClass] / [LayoutBuilder] to branch
/// layouts, and [MaxWidthContent] to stop content from stretching
/// unnaturally wide on large screens.
enum WindowSize {
  /// Phones in portrait, and small windows. < 600
  compact,

  /// Phones in landscape, small tablets, foldables. 600–839
  medium,

  /// Tablets, desktop windows. 840–1199
  expanded,

  /// Large desktop windows. >= 1200
  large,
}

/// Material 3 window-size-class breakpoints (logical pixels).
abstract final class Breakpoints {
  const Breakpoints._();

  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  /// Comfortable reading/measure width for forms and text blocks.
  static const double readableContent = 560;

  /// Max width for a dashboard / detail content column on wide screens.
  static const double dashboardContent = 1400;

  /// Target max width of a single auction card, used to derive the column
  /// count via [SliverGridDelegateWithMaxCrossAxisExtent]. A phone (~316 dp of
  /// usable width) yields 2 columns; tablets/foldables get 3+.
  static const double auctionCardMaxExtent = 220;
}

WindowSize _classify(double width) {
  if (width >= Breakpoints.large) return WindowSize.large;
  if (width >= Breakpoints.expanded) return WindowSize.expanded;
  if (width >= Breakpoints.medium) return WindowSize.medium;
  return WindowSize.compact;
}

/// Convenience accessors derived from the current window size.
extension ResponsiveContext on BuildContext {
  /// The [WindowSize] of the whole app window. For layout decisions scoped to a
  /// sub-tree, prefer a [LayoutBuilder] and [Breakpoints] directly.
  WindowSize get widthClass => _classify(MediaQuery.sizeOf(this).width);

  /// True when the window is at least tablet-width (>= 600).
  bool get isWide => widthClass != WindowSize.compact;

  /// True for tablet/desktop-class windows (>= 840).
  bool get isExpanded =>
      widthClass == WindowSize.expanded || widthClass == WindowSize.large;
}

/// Centers [child] and caps its width at [maxWidth] so forms, text blocks and
/// dashboards stay readable on large screens instead of stretching edge to
/// edge. On narrow windows it is a transparent pass-through.
class MaxWidthContent extends StatelessWidget {
  const MaxWidthContent({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.dashboardContent,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}
