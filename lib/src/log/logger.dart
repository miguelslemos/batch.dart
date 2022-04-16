// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:meta/meta.dart';

// Project imports:
import 'package:batch/src/log/color/log_color.dart';
import 'package:batch/src/log/filter/default_log_filter.dart';
import 'package:batch/src/log/filter/log_filter.dart';
import 'package:batch/src/log/input_log_event.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/log_level.dart';
import 'package:batch/src/log/output/console_log_output.dart';
import 'package:batch/src/log/output/log_output.dart';
import 'package:batch/src/log/output_log_event.dart';
import 'package:batch/src/log/printer/default_log_printer.dart';
import 'package:batch/src/log/printer/log_printer.dart';

class Logger {
  /// Returns the new instance of [Logger].
  Logger.loadFrom({required LogConfiguration config})
      : _filter = config.filter ?? DefaultLogFilter(),
        _printer = config.printer ?? DefaultLogPrinter(),
        _output = config.output ?? ConsoleLogOutput(),
        _printLog = config.printLog {
    _filter.init();
    _printer.init();
    _output.init();

    _filter.level = config.level ?? LogLevel.trace;
    _output.logColor = config.color ?? LogColor();

    // Holds the Logger instance.
    _singletonInstance = this;
  }

  /// Returns the singleton instance of [Logger].
  static get instance => _singletonInstance;

  /// The singleton instance of this [Logger].
  static Logger? _singletonInstance;

  /// The filter
  final LogFilter _filter;

  /// The printer
  final LogPrinter _printer;

  /// The output
  final LogOutput _output;

  /// The flag represents this logger should print log or not
  final bool _printLog;

  /// The flag represents this logger is active or not
  bool _active = true;

  /// Log a message at trace level.
  void trace(dynamic message) => _log(LogLevel.trace, message);

  /// Log a message at debug level.
  void debug(dynamic message) => _log(LogLevel.debug, message);

  /// Log a message at info level.
  void info(dynamic message) => _log(LogLevel.info, message);

  /// Log a message at warn level.
  void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.warn, message, error, stackTrace);

  /// Log a message at error level.
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);

  /// Log a message at fatal level.
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.fatal, message, error, stackTrace);

  @visibleForTesting
  void dispose() {
    _active = false;
    _filter.dispose();
    _printer.dispose();
    _output.dispose();
  }

  /// Log a message with [level].
  void _log(
    LogLevel level,
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_printLog) {
      /// Do nothing when log output is disabled.
      return;
    }

    if (!_active) {
      throw ArgumentError('Logger has already been disposed.');
    }

    if (error != null && error is StackTrace) {
      throw ArgumentError('The "error" parameter cannot take a StackTrace.');
    }

    final inputEvent = InputLogEvent(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    if (_filter.shouldLog(inputEvent)) {
      final output = _printer.log(inputEvent);

      if (output.isNotEmpty) {
        final outputEvent = OutputLogEvent(
          level: level,
          lines: output,
        );

        try {
          _output.output(outputEvent);
        } catch (error, stackTrace) {
          print(error);
          print(stackTrace);
        }
      }
    }
  }
}
