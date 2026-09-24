import 'package:intl/intl.dart';

/// Helper utilitas untuk memformat tanggal dan waktu dalam Bahasa Indonesia
class DateFormatter {
  DateFormatter._();

  static final DateFormat _indonesianDateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _indonesianTimeFormat = DateFormat('HH:mm', 'id_ID');
  static final DateFormat _indonesianDateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  /// Format tanggal: "21 September 2026"
  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (_) {
      return date.toIso8601String().split('T').first;
    }
  }

  /// Format jam: "10:00"
  static String formatTime(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('HH:mm').format(date);
    } catch (_) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Format tanggal & jam: "21 Sep 2026, 10:00"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return '${formatDate(date)} ${formatTime(date)}';
    }
  }

  /// Parse dari string ISO atau format SQL "2026-09-21 10:00"
  static DateTime? parse(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return DateTime.parse(dateStr.trim().replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }
}
