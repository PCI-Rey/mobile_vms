String formatDate(DateTime date) {
  // Output: Mon, 26 June 2025
  return "${weekdayMap[date.weekday]}, ${date.day} ${monthMap[date.month]} ${date.year}";
}

String formatTime(DateTime time) {
  return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
}

const weekdayMap = {
  1: 'Mon',
  2: 'Tue',
  3: 'Wed',
  4: 'Thu',
  5: 'Fri',
  6: 'Sat',
  7: 'Sun',
};

const monthMap = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};

DateTime combineDateTime(DateTime date, String time) {
  final parts = time.split(':');
  return DateTime(
    date.year,
    date.month,
    date.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}

