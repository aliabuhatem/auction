import 'package:intl/intl.dart';

/// All currency / number formatting for the app (Euro / Dutch locale).
class CurrencyFormatter {
  CurrencyFormatter._();

  // ── Formatters ────────────────────────────────────────────────────────────

  static final _euro      = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 2);
  static final _euroWhole = NumberFormat.currency(locale: 'nl_NL', symbol: '€', decimalDigits: 0);
  static final _compact   = NumberFormat.compact(locale: 'nl_NL');
  static final _decimal   = NumberFormat('#,##0.00',  'nl_NL');
  static final _integer   = NumberFormat('#,##0',     'nl_NL');

  // ── Core formatters ───────────────────────────────────────────────────────

  /// Standard euro format: € 1.234,56
  static String format(double amount) => _euro.format(amount);

  /// Euro without cents (for round values): € 1.235
  static String formatWhole(double amount) => _euroWhole.format(amount.roundToDouble());

  /// Smart format: shows decimals only if needed.
  /// €1 → "€ 1",  €1.50 → "€ 1,50"
  static String formatSmart(double amount) {
    if (amount == amount.truncateToDouble()) return formatWhole(amount);
    return format(amount);
  }

  /// Compact format for large numbers:
  /// 1234 → "€ 1,2K",  999000 → "€ 999K"
  static String formatCompact(double amount) {
    if (amount >= 1000) return '€ ${_compact.format(amount)}';
    return format(amount);
  }

  /// Range display: "€ 10 – € 500"
  static String formatRange(double min, double max) =>
      '${format(min)} – ${format(max)}';

  // ── Savings & percentage ──────────────────────────────────────────────────

  /// Savings in euros: "-€ 47,50"
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

  /// Savings percent as a double: 0.34 → "34%"
  static String percent(double value) => '${(value * 100).toStringAsFixed(0)}%';

  // ── Bid formatting ────────────────────────────────────────────────────────

  /// Next bid label: "Bied € 24,00"
  static String nextBidLabel(double currentBid, {double increment = 1.0}) =>
      'Bied ${format(currentBid + increment)}';

  /// Minimum bid label: "Minimale bieding: € 1,00"
  static String minBidLabel(double amount) => 'Minimale bieding: ${format(amount)}';

  // ── Plain number helpers ──────────────────────────────────────────────────

  /// Formats a plain number with Dutch thousands separator: 1234 → "1.234"
  static String number(double value) => _integer.format(value.truncate());

  /// Formatted with 2 decimal places: 1234.5 → "1.234,50"
  static String decimal(double value) => _decimal.format(value);



  // ── Parsing ───────────────────────────────────────────────────────────────

  /// Safely parse a currency string back to double.
  /// Handles "€ 1.234,56" → 1234.56
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
