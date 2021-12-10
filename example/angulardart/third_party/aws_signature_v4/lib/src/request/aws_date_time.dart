import 'dart:math';

/// {@template aws_date_time}
/// A utility class which wraps [DateTime] objects.
///
/// Used for formatting dates and times throughout the signing process.
/// {@endtemplate}
class AWSDateTime {
  final DateTime _dateTime;

  /// {@macro aws_date_time}
  AWSDateTime(DateTime dateTime) : _dateTime = dateTime.toUtc();

  /// {@macro aws_date_time}
  ///
  /// Uses [DateTime.now] as the input.
  AWSDateTime.now() : _dateTime = DateTime.now().toUtc();

  /// Formats the date and time as `YYYYMMDDTHHMMSSZ`.
  String formatFull() => formatDate() + 'T' + formatTime() + 'Z';

  /// Formats the date as `YYYYMMDD`.
  String formatDate() =>
      _padZeros('${_dateTime.year}', 4) +
      _padZeros('${_dateTime.month}', 2) +
      _padZeros('${_dateTime.day}', 2);

  /// Formats the time as `HHMMSS`.
  String formatTime() =>
      _padZeros('${_dateTime.hour}', 2) +
      _padZeros('${_dateTime.minute}', 2) +
      _padZeros('${_dateTime.second}', 2);

  /// Ensures that [str] is exactly [length] characters long by padding the
  /// front with `0` characters.
  static String _padZeros(String str, int length) {
    return '0' * max(0, length - str.length) + str;
  }

  @override
  String toString() => formatFull();
}
