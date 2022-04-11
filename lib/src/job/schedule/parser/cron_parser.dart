// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/error/schedule_parse_error.dart';
import 'package:batch/src/job/schedule/model/cron.dart';
import 'package:batch/src/job/schedule/parser/schedule_parser.dart';

/// The convenient parser for Cron schedule.
///
/// **_The supported cron format:_**
///
/// ```
/// -----------
/// * * * * * *
/// -----------
/// | | | | | |
/// | | | | | +-- Weekdays  (range: 0-7)
/// | | | | +---- Months    (range: 1-12)
/// | | | +------ Days      (range: 1-31)
/// | | +-------- Hours     (range: 0-23)
/// | +---------- Minutes   (range: 0-59)
/// +------------ Seconds   (range: 0-59, it will be interpreted as "*" if it's omitted)
/// ```
class CronParser extends ScheduleParser<Cron> {
  /// Returns the new instance of [CronParser].
  CronParser({
    required String value,
  }) : _value = value;

  /// The value in cron format
  final String _value;

  /// The regex for whitespace
  final _whitespaceRegExp = RegExp('\\s+');

  @override
  Cron parse() {
    List<String?> fields = _value
        .split(_whitespaceRegExp)
        .where((part) => part.isNotEmpty)
        .toList();

    if (fields.length < 5) {
      throw ScheduleParseError(
        '''
The Cron format needs to consist of 5 fields at least.
 -----------
 * * * * * *
 -----------
 | | | | | |
 | | | | | +-- Weekdays  (range: 0-7)
 | | | | +---- Months    (range: 1-12)
 | | | +------ Days      (range: 1-31)
 | | +-------- Hours     (range: 0-23)
 | +---------- Minutes   (range: 0-59)
 +------------ Seconds   (range: 0-59, it will be interpreted as "*" if it's omitted)''',
      );
    }

    fields = [
      if (fields.length == 5) null,
      ...fields,
    ];

    return _parse(
      seconds: fields[0],
      minutes: fields[1],
      hours: fields[2],
      days: fields[3],
      months: fields[4],
      weekdays: fields[5],
    );
  }

  Cron _parse({
    required String? seconds,
    required String? minutes,
    required String? hours,
    required String? days,
    required String? months,
    required String? weekdays,
  }) {
    final parsedSeconds =
        _parseConstraint(seconds)?.where((x) => x >= 0 && x <= 59).toList();
    final parsedMinutes =
        _parseConstraint(minutes)?.where((x) => x >= 0 && x <= 59).toList();
    final parsedHours =
        _parseConstraint(hours)?.where((x) => x >= 0 && x <= 23).toList();
    final parsedDays =
        _parseConstraint(days)?.where((x) => x >= 1 && x <= 31).toList();
    final parsedMonths =
        _parseConstraint(months)?.where((x) => x >= 1 && x <= 12).toList();
    final parsedWeekdays = _parseConstraint(weekdays)
        ?.where((x) => x >= 0 && x <= 7)
        .map((x) => x == 0 ? 7 : x)
        .toSet()
        .toList();

    return Cron(
      seconds: parsedSeconds,
      minutes: parsedMinutes,
      hours: parsedHours,
      days: parsedDays,
      months: parsedMonths,
      weekdays: parsedWeekdays,
    );
  }

  List<int>? _parseConstraint(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value == '*') return null;

    final parts = value.split(',');
    if (parts.length > 1) {
      final items = parts
          .map(_parseConstraint)
          .expand((list) => list!)
          .toSet()
          .toList()
            ..sort();

      return items;
    }

    final singleValue = int.tryParse(value);
    if (singleValue != null) {
      return [singleValue];
    }

    if (value.startsWith('*/')) {
      final period = int.tryParse(value.substring(2)) ?? -1;
      if (period > 0) {
        return List.generate(120 ~/ period, (i) => i * period);
      }
    }

    if (value.contains('-')) {
      final ranges = value.split('-');

      if (ranges.length == 2) {
        final lower = int.tryParse(ranges.first) ?? -1;
        final higher = int.tryParse(ranges.last) ?? -1;

        if (lower <= higher) {
          return List.generate(higher - lower + 1, (i) => i + lower);
        }
      }
    }

    throw ScheduleParseError('Unable to parse: $value');
  }
}
