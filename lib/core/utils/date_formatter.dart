import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _fullDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeOnly = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy • HH:mm');

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYear.format(date);
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return '';
    return _fullDate.format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeOnly.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTime.format(date);
  }

  static String formatPeriod(DateTime? start, DateTime? end, bool isCurrent) {
    final startStr = formatMonthYear(start);
    if (startStr.isEmpty) return '';
    if (isCurrent) return '$startStr - Present';
    final endStr = formatMonthYear(end);
    return endStr.isNotEmpty ? '$startStr - $endStr' : startStr;
  }
}
