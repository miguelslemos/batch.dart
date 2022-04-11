// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/log/input_log_event.dart';
import 'package:batch/src/log/log_level.dart';
import 'package:batch/src/log/printer/log_printer.dart';

/// The default printer.
class DefaultLogPrinter extends LogPrinter {
  /// Returns the new instance of [DefaultLogPrinter].
  DefaultLogPrinter({String? dateTimePattern})
      : super(dateTimePattern: dateTimePattern);

  @override
  List<String> log(final InputLogEvent event) => _buildBuffer(event);

  /// Returns the buffered log messages.
  List<String> _buildBuffer(final InputLogEvent event) {
    final buffer = <String>[];
    buffer.add('${_buildHeader(event)} - ${message(event)}');

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
      '${now()} [${logLevel(event)}] (${executedMethod()})';
}
