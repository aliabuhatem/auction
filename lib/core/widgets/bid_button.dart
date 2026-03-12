import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/currency_formatter.dart';

// ── Primary bid button ────────────────────────────────────────────────────────

/// The main "Bied € X,00" call-to-action button with gradient, shadow,
/// press animation, and loading state.
class BidButton extends StatefulWidget {
  final double nextBid;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onTap;
  final String? customLabel;

  const BidButton({
    super.key,
    required this.nextBid,
    this.isLoading  = false,
    this.isDisabled = false,
    this.onTap,
    this.customLabel,
  });

  @override
  State<BidButton> createState() => _BidButtonState();
}

class _BidButtonState extends State<BidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isLoading && !widget.isDisabled && widget.onTap != null;

  void _onTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width:  double.infinity,
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            gradient: _isEnabled
                ? const LinearGradient(
                    colors: [Color(0xFFE63946), Color(0xFFc1121f)],
                    begin:  Alignment.topLeft,
                    end:    Alignment.bottomRight,
                  )
                : null,
            color: _isEnabled ? null : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            boxShadow: _isEnabled
                ? [
                    BoxShadow(
                      color:      AppColors.primaryRed.withOpacity(0.40),
                      blurRadius: 14,
                      offset:     const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width:  24,
                    height: 24,
                    child:  CircularProgressIndicator(
                      color:       Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.customLabel ??
                        'Bied ${CurrencyFormatter.format(widget.nextBid)}',
                    style: TextStyle(
                      color:       _isEnabled ? Colors.white : Colors.grey.shade600,
                      fontSize:    AppDimensions.fontXXL,
                      fontWeight:  FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Secondary outline alarm button ───────────────────────────────────────────

class AlarmButton extends StatefulWidget {
  final bool isSet;
  final bool isLoading;
  final VoidCallback? onTap;

  const AlarmButton({
    super.key,
    this.isSet    = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<AlarmButton> createState() => _AlarmButtonState();
}

class _AlarmButtonState extends State<AlarmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.isLoading || widget.onTap == null) return;
    HapticFeedback.selectionClick();
    _shake.forward(from: 0);
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width:  double.infinity,
        height: AppDimensions.buttonHeightS,
        decoration: BoxDecoration(
          color: widget.isSet
              ? AppColors.primaryRed.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          border: Border.all(
            color: widget.isSet ? AppColors.primaryRed : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryRed,
                ),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isSet ? Icons.alarm_on : Icons.alarm,
                  key:   ValueKey(widget.isSet),
                  color: widget.isSet ? AppColors.primaryRed : Colors.grey.shade600,
                  size:  AppDimensions.iconS,
                ),
              ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color:      widget.isSet ? AppColors.primaryRed : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize:   AppDimensions.fontBody,
              ),
              child: Text(widget.isSet ? 'Alarm ingesteld ✓' : 'Stel alarm in'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Watchlist (heart) icon button ─────────────────────────────────────────────

class WatchlistButton extends StatefulWidget {
  final bool isSaved;
  final VoidCallback? onTap;

  const WatchlistButton({super.key, this.isSaved = false, this.onTap});

  @override
  State<WatchlistButton> createState() => _WatchlistButtonState();
}

class _WatchlistButtonState extends State<WatchlistButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _burst;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _burst, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _burst.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.isSaved ? Icons.favorite : Icons.favorite_border,
              key:   ValueKey(widget.isSaved),
              color: widget.isSaved ? AppColors.primaryRed : Colors.grey.shade600,
              size:  AppDimensions.iconS,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small pill "Bied nu" quick-action button ──────────────────────────────────

class QuickBidBadge extends StatelessWidget {
  final VoidCallback? onTap;
  const QuickBidBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        AppColors.primaryRed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        child: const Text(
          'Bied nu',
          style: TextStyle(
            color:      Colors.white,
            fontWeight: FontWeight.bold,
            fontSize:   AppDimensions.fontS,
          ),
        ),
      ),
    );
  }
}
