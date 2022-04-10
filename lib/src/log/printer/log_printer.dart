// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:batch/src/log/input_log_event.dart';

abstract class LogPrinter {
  /// Returns the new instance of [LogPrinter].
  LogPrinter({String? dateTimePattern})
      : _dateFormat = DateFormat(dateTimePattern ?? _defaultDateTimePattern);

  /// The default datetime pattern
  static const _defaultDateTimePattern = 'yyyy-MM-dd HH:mm:ss.SSS';

  /// The maximum width of executed method on log
  static const _defaultMaxWidth = 30;

  /// The date time format
  final DateFormat _dateFormat;

  void init() {}

  /// Is called every time a new [LogInputEvent] is sent and handles printing or
  /// storing the message.
  List<String> log(final InputLogEvent event);

  void dispose() {}

  /// Returns the formatted current date time.
  String now({
    int? padRightWidth,
    String? padRightPattern,
  }) =>
      _dateFormat
          .format(DateTime.now())
          .padRight(padRightWidth ?? 23, padRightPattern ?? '0');

  /// Returns the formatted log level.
  String logLevel(
    final InputLogEvent event, {
    int? padRightWidth,
    String? padRightPattern,
  }) =>
      event.level.name.padRight(padRightWidth ?? 5, padRightPattern ?? ' ');

  /// Returns the message in string.
  /// The argument [message] is executed if it's a function.
  String message(final InputLogEvent event) =>
      event.message is Function ? event.message() : event.message.toString();

  /// Returns the executed method according to current stack trace.
  String executedMethod({int? width}) {
    final trace = StackTrace.current.toString().split('#6')[1];
    final executedInfo = trace.substring(0, trace.indexOf(')')).trim();

    final methodName =
        executedInfo.substring(0, executedInfo.lastIndexOf(' ')).trim();
    final position = executedInfo
        .substring(executedInfo.lastIndexOf('.dart') + 5, executedInfo.length)
        .trim();

    final executedMethod = '$methodName$position';
    final maxWidth = width ?? _defaultMaxWidth;

    return executedMethod.length <= maxWidth
        ? executedMethod.padRight(maxWidth)
        : executedMethod.substring((executedMethod.length - maxWidth));
  }
}
