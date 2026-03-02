import 'dart:async';

/// A self-managing countdown timer that fires a callback every second.
/// Attach to a StatefulWidget and call [start] in initState, [dispose] in dispose.
class CountdownTimer {
  final DateTime endsAt;
  final void Function(Duration remaining) onTick;
  final void Function()? onEnd;
  final Duration interval;

  Timer? _timer;
  bool _isRunning = false;

  CountdownTimer({
    required this.endsAt,
    required this.onTick,
    this.onEnd,
    this.interval = const Duration(seconds: 1),
  });

  // ── State ────────────────────────────────────────────────────────────────

  bool get isRunning => _isRunning;
  bool get isExpired => DateTime.now().isAfter(endsAt);

  Duration get remaining {
    final r = endsAt.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  // Urgency helpers
  bool get isEnding  => remaining.inMinutes < 10;
  bool get isUrgent  => remaining.inSeconds < 60;
  bool get isCritical => remaining.inSeconds < 10;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // Fire immediately so the UI shows the right value right away
    onTick(remaining);

    _timer = Timer.periodic(interval, (_) {
      final r = remaining;
      onTick(r);
      if (r == Duration.zero) {
        stop();
        onEnd?.call();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void restart() {
    stop();
    start();
  }

  void dispose() => stop();

  // ── Static formatting helpers ────────────────────────────────────────────

  /// Formats a Duration into a human-readable countdown string.
  ///
  /// Examples:
  ///   Duration(days: 3)                 → "3d 4u"
  ///   Duration(hours: 2, minutes: 15)  → "02:15:00"
  ///   Duration(minutes: 4, seconds: 5) → "04:05"
  ///   Duration.zero                    → "00:00"
  static String format(Duration d) {
    if (d.inDays >= 1) {
      final days  = d.inDays;
      final hours = d.inHours % 24;
      return '${days}d ${hours}u';
    }
    if (d.inHours >= 1) {
      final h = _pad(d.inHours);
      final m = _pad(d.inMinutes % 60);
      final s = _pad(d.inSeconds % 60);
      return '$h:$m:$s';
    }
    final m = _pad(d.inMinutes);
    final s = _pad(d.inSeconds % 60);
    return '$m:$s';
  }

  /// Short format — drops hours if < 1h:
  ///   Duration(hours: 5) → "5:00:00"
  ///   Duration(minutes: 9, seconds: 3) → "09:03"
  static String formatShort(Duration d) => format(d);

  /// Long format with Dutch labels:
  ///   "3 dagen",  "2 uur",  "45 min",  "30 sec"
  static String formatVerbose(Duration d) {
    if (d.inDays    >= 1)  return '${d.inDays} dag${d.inDays == 1 ? '' : 'en'}';
    if (d.inHours   >= 1)  return '${d.inHours} uur';
    if (d.inMinutes >= 1)  return '${d.inMinutes} min';
    return '${d.inSeconds} sec';
  }

  /// Returns the urgency level for colour-coding:
  ///   0 = normal (green), 1 = warning (orange), 2 = critical (red)
  static int urgencyLevel(Duration d) {
    if (d.inSeconds <  60) return 2; // < 1 min  — red
    if (d.inMinutes < 10)  return 1; // < 10 min — orange
    return 0;                        // ≥ 10 min  — green
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}
