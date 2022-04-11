// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/log/input_log_event.dart';
import 'package:batch/src/log/log_level.dart';
import 'package:batch/src/log/printer/default_log_printer.dart';

void main() {
  test('Test DefaultLogPrinter', () {
    final printer = DefaultLogPrinter();
    final message = printer.log(InputLogEvent(
        level: LogLevel.debug, message: 'test', error: null, stackTrace: null));

    expect(() => printer.init(), returnsNormally);
    expect(message[0].substring(message[0].indexOf('[')),
        '[debug] (test.<anonymous closure>:197:7) - test');
    expect(() => printer.dispose(), returnsNormally);
  });
}
