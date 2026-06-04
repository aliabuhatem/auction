import 'package:intl/intl.dart';

/// All date/time formatting helpers for the app (Dutch locale by default).
class DateFormatter {
  DateFormatter._();

  // ── Formatters ────────────────────────────────────────────────────────────

  static final _date       = DateFormat('dd-MM-yyyy',              'nl_NL');
  static final _time       = DateFormat('HH:mm',                   'nl_NL');
  static final _dateTime   = DateFormat('dd-MM-yyyy HH:mm',        'nl_NL');
  static final _dayMonth   = DateFormat('d MMM',                   'nl_NL');
  static final _monthYear  = DateFormat('MMMM yyyy',               'nl_NL');
  static final _dayOfWeek  = DateFormat('EEEE',                    'nl_NL');
  static final _fullDate   = DateFormat('EEEE d MMMM yyyy',        'nl_NL');
  static final _compact    = DateFormat('d MMM yyyy',              'nl_NL');
  static final _isoDate    = DateFormat('yyyy-MM-dd');

  // ── Basic formatters ──────────────────────────────────────────────────────

  /// 31-12-2024
  static String date(DateTime dt)       => _date.format(dt);

  /// 14:30
  static String time(DateTime dt)       => _time.format(dt);

  /// 31-12-2024 14:30
  static String dateTime(DateTime dt)   => _dateTime.format(dt);

  /// 31 dec
  static String shortDate(DateTime dt)  => _dayMonth.format(dt);

  /// december 2024
  static String monthYear(DateTime dt)  => _monthYear.format(dt);

  /// vrijdag
  static String dayOfWeek(DateTime dt)  => _dayOfWeek.format(dt);

  /// vrijdag 31 december 2024
  static String fullDate(DateTime dt)   => _fullDate.format(dt);

  /// 31 dec 2024
  static String compact(DateTime dt)    => _compact.format(dt);

  /// 2024-12-31
  static String isoDate(DateTime dt)    => _isoDate.format(dt);

  // ── Relative time (timeAgo) ───────────────────────────────────────────────

  /// Returns a human-readable relative time string, locale-aware.
  /// Pass [locale] from `Localizations.localeOf(context).languageCode`.
  static String timeAgo(DateTime dt, {String locale = 'nl'}) {
    final diff = DateTime.now().difference(dt);
    if (locale.startsWith('ar')) return _timeAgoAr(diff);
    if (locale.startsWith('en')) return _timeAgoEn(diff);
    return _timeAgoNl(diff);
  }

  static String _timeAgoNl(Duration diff) {
    if (diff.inSeconds <  5)   return 'net nu';
    if (diff.inSeconds < 60)   return '${diff.inSeconds}s geleden';
    if (diff.inMinutes <  2)   return '1 minuut geleden';
    if (diff.inMinutes < 60)   return '${diff.inMinutes} minuten geleden';
    if (diff.inHours   <  2)   return '1 uur geleden';
    if (diff.inHours   < 24)   return '${diff.inHours} uur geleden';
    if (diff.inDays    <  2)   return 'gisteren';
    if (diff.inDays    <  7)   return '${diff.inDays} dagen geleden';
    if (diff.inDays    < 14)   return 'vorige week';
    if (diff.inDays    < 31)   return '${(diff.inDays / 7).floor()} weken geleden';
    if (diff.inDays    < 365)  return '${(diff.inDays / 30).floor()} maanden geleden';
    return '${(diff.inDays / 365).floor()} jaar geleden';
  }

  static String _timeAgoEn(Duration diff) {
    if (diff.inSeconds <  5)   return 'just now';
    if (diff.inSeconds < 60)   return '${diff.inSeconds}s ago';
    if (diff.inMinutes <  2)   return '1 minute ago';
    if (diff.inMinutes < 60)   return '${diff.inMinutes} minutes ago';
    if (diff.inHours   <  2)   return '1 hour ago';
    if (diff.inHours   < 24)   return '${diff.inHours} hours ago';
    if (diff.inDays    <  2)   return 'yesterday';
    if (diff.inDays    <  7)   return '${diff.inDays} days ago';
    if (diff.inDays    < 14)   return 'last week';
    if (diff.inDays    < 31)   return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays    < 365)  return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} year(s) ago';
  }

  static String _timeAgoAr(Duration diff) {
    if (diff.inSeconds <  5)   return 'الآن';
    if (diff.inSeconds < 60)   return 'منذ ${diff.inSeconds}ث';
    if (diff.inMinutes <  2)   return 'منذ دقيقة';
    if (diff.inMinutes < 60)   return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours   <  2)   return 'منذ ساعة';
    if (diff.inHours   < 24)   return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays    <  2)   return 'أمس';
    if (diff.inDays    <  7)   return 'منذ ${diff.inDays} أيام';
    if (diff.inDays    < 14)   return 'الأسبوع الماضي';
    if (diff.inDays    < 31)   return 'منذ ${(diff.inDays / 7).floor()} أسابيع';
    if (diff.inDays    < 365)  return 'منذ ${(diff.inDays / 30).floor()} شهور';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  // ── Countdown display ─────────────────────────────────────────────────────

  /// Returns a compact "expires in" string for vouchers:
  /// "3 maanden", "12 dagen", "3 uur", "45 minuten", "Verlopen"
  static String expiresIn(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative)        return 'Verlopen';
    if (diff.inDays    > 60)    return '${(diff.inDays / 30).floor()} maanden';
    if (diff.inDays    >= 1)    return '${diff.inDays} dag${diff.inDays == 1 ? '' : 'en'}';
    if (diff.inHours   >= 1)    return '${diff.inHours} uur';
    if (diff.inMinutes >= 1)    return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 'n'}';
    return 'Minder dan een minuut';
  }

  // ── Auction helpers ───────────────────────────────────────────────────────

  /// Returns a label for when an auction ends, e.g. "vandaag 14:30" or "31 dec"
  static String auctionEndLabel(DateTime endsAt) {
    final now = DateTime.now();
    if (endsAt.isBefore(now)) return 'Afgelopen';
    final diff = endsAt.difference(now);
    if (diff.inHours < 24 && endsAt.day == now.day) {
      return 'vandaag om ${time(endsAt)}';
    }
    if (diff.inDays == 0) return 'morgen om ${time(endsAt)}';
    if (diff.inDays < 7)  return '${dayOfWeek(endsAt)} om ${time(endsAt)}';
    return '${shortDate(endsAt)} om ${time(endsAt)}';
  }

  /// Formats a bid timestamp compactly for the bid history list.
  static String bidTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60)  return '${diff.inSeconds}s geleden';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m geleden';
    if (diff.inHours   < 24)  return '${diff.inHours}u geleden';
    return date(dt);
  }

  // ── ISO / parsing helpers ─────────────────────────────────────────────────

  /// Safely parse an ISO 8601 string, returns null if invalid.
  static DateTime? tryParse(String? s) {
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  /// Returns true if two DateTimes are on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns true if [dt] is today.
  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  /// Returns true if [dt] was yesterday.
  static bool isYesterday(DateTime dt) =>
      isSameDay(dt, DateTime.now().subtract(const Duration(days: 1)));
}
