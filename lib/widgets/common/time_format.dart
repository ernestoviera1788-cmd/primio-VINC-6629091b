import 'package:intl/intl.dart';

String relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';
  return DateFormat('d MMM', 'es').format(t);
}

String clockTime(DateTime t) => DateFormat('HH:mm', 'es').format(t);

String shortDate(DateTime t) => DateFormat('d MMM yyyy', 'es').format(t);
