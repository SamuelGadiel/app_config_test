class DateTimeHelper {
  static String get convertCurrentDateToServerTime =>
      '${DateTime.now().toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first}Z';

  static String get serverTimeFormatted => convertCurrentDateToServerTime.substring(0, 8);
}
