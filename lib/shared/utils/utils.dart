import 'package:intl/intl.dart';

String formatMessageTime(DateTime? dateTime) {
  if (dateTime == null) {
    return "";
  }
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    return DateFormat('hh:mm a').format(dateTime); // Today
  } else if (difference.inDays == 1) {
    return 'Yesterday ${DateFormat('hh:mm a').format(dateTime)}';
  } else {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime); // Older
  }
}
