import 'package:intl/intl.dart';

class DateFormatter {
  static String matchTime(DateTime? dateTime) {
    if (dateTime == null) return 'Time TBD';
    return DateFormat('EEE, MMM d • HH:mm').format(dateTime.toLocal());
  }
}
