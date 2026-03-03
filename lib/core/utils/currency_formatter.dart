import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  // ── Formatters ────────────────────────────────────────────────────────────

  static final _euro      = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 2);
  static final _euroWhole = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
  static final _compact   = NumberFormat.compact(locale: 'nl_NL');
  static final _decimal   = NumberFormat('#,##0.00',  'nl_NL');
  static final _integer   = NumberFormat('#,##0',     'nl_NL');

  // ── Core formatters ───────────────────────────────────────────────────────

  static String format(double amount) => _euro.format(amount);
  static String formatWhole(double amount) => _euroWhole.format(amount.roundToDouble());
  static String formatSmart(double amount) {
    if (amount == amount.truncateToDouble()) return formatWhole(amount);
    return format(amount);
  }


  static String formatCompact(double amount) {
    if (amount >= 1000) return '€ ${_compact.format(amount)}';
    return format(amount);
  }

  static String formatRange(double min, double max) =>
      '${format(min)} – ${format(max)}';



  static String formatSavings(double retail, double current) {
    final savings = retail - current;
    if (savings <= 0) return format(0);
    return '-${format(savings)}';
  }

  /// Percentage discount: "34%"
  static String formatDiscountPercent(double retail, double current) {
    if (retail <= 0) return '0%';
    final pct = ((retail - current) / retail * 100).clamp(0.0, 100.0);
    return '${pct.toStringAsFixed(0)}%';
  }

  static String percent(double value) => '${(value * 100).toStringAsFixed(0)}%';

  // ── Bid formatting ────────

  static String nextBidLabel(double currentBid, {double increment = 1.0}) =>
      'Bied ${format(currentBid + increment)}';
  static String minBidLabel(double amount) => 'Minimale bieding: ${format(amount)}';

  // ── Plain number helpers ──────

  static String number(double value) => _integer.format(value.truncate());
  static String decimal(double value) => _decimal.format(value);



  // ── Parsing ────────────────────

  static double? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final cleaned = raw
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned);
  }
}
