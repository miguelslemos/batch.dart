// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/schedule/model/schedule.dart';

class CronSchedule extends Schedule {
  /// Returns the new instance of [CronSchedule].
  CronSchedule({
    required List<int>? seconds,
    required List<int>? minutes,
    required List<int>? hours,
    required List<int>? days,
    required List<int>? months,
    required List<int>? weekdays,
  }) : super(
          seconds: seconds,
          minutes: minutes,
          hours: hours,
          days: days,
          months: months,
          weekdays: weekdays,
        );

  @override
  bool shouldRunAt(final DateTime time) {
    if (seconds?.contains(time.second) == false) return false;
    if (minutes?.contains(time.minute) == false) return false;
    if (hours?.contains(time.hour) == false) return false;
    if (days?.contains(time.day) == false) return false;
    if (months?.contains(time.month) == false) return false;
    if (weekdays?.contains(time.weekday) == false) return false;
    return true;
  }
}
