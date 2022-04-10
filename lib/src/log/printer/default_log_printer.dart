// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/log/input_log_event.dart';
import 'package:batch/src/log/log_level.dart';
import 'package:batch/src/log/printer/log_printer.dart';

/// The default printer.
class DefaultLogPrinter extends LogPrinter {
  /// The maximum width of step on log
  static const _maxWidthStep = 30;

  @override
  List<String> log(final InputLogEvent event) => _buildBuffer(event);

  /// Returns the buffered log messages.
  List<String> _buildBuffer(final InputLogEvent event) {
    final buffer = <String>[];
    buffer.add('${_buildHeader(event)} - ${_stringifyMessage(event.message)}');

    if (event.error != null) {
      buffer.add(event.error.toString());
    }

    if (event.stackTrace != null) {
      buffer.add(event.stackTrace.toString());
    }

    return buffer;
  }

  /// Returns the header of log.
  String _buildHeader(final InputLogEvent event) =>
      '$_currentDateTime [${_logLevel(event)}] ($_executedStep)';

  /// Returns the message in string.
  /// The argument [message] is executed if it's a function.
  String _stringifyMessage(final dynamic message) =>
      message is Function ? message() : message.toString();

  /// Returns the formatted current datetime.
  String get _currentDateTime => DateTime.now().toString().padRight(26, '0');

  /// Returns the formatted log level.
  String _logLevel(final InputLogEvent event) =>
      event.level.name.padRight(5, ' ');

  /// Returns the executed step according to current stack trace.
  String get _executedStep {
    final String traces = StackTrace.current.toString().split('#6')[1];
    final executedStep = traces.substring(0, traces.indexOf(')')).trim();
    final method =
        executedStep.substring(0, executedStep.lastIndexOf(' ')).trim();
    final place = executedStep
        .substring(executedStep.lastIndexOf('.dart') + 5, executedStep.length)
        .trim();

    return _prettifyStep('$method$place');
  }

  /// Returns the formatted step.
  String _prettifyStep(final String step) {
    if (step.length <= _maxWidthStep) {
      return step.padRight(_maxWidthStep);
    }

    return step.substring((step.length - _maxWidthStep));
  }
}
