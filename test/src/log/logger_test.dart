// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/batch.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  test('Test Logger', () {
    final logger = Logger.loadFromConfig(LogConfiguration());
    expect(() => logger.trace('test trace'), returnsNormally);
    expect(() => logger.debug('test debug'), returnsNormally);
    expect(() => logger.info('test info'), returnsNormally);
    expect(() => logger.warn('test warn'), returnsNormally);
    expect(() => logger.error('test error'), returnsNormally);
    expect(() => logger.fatal('test fatal'), returnsNormally);

    logger.dispose();
  });

  test('Test Logger after dispose', () {
    final logger = Logger.loadFromConfig(LogConfiguration());
    logger.dispose();

    expect(
      () => logger.trace('Not printed'),
      throwsA(
        allOf(
          isA<ArgumentError>(),
          predicate(
              (dynamic e) => e.message == 'Logger has already been disposed.'),
        ),
      ),
    );
  });

  test('Test when error is StackTrace', () {
    final logger = Logger.loadFromConfig(LogConfiguration());

    expect(
      () => logger.warn('error is StackTrace', StackTrace.current),
      throwsA(
        allOf(
          isA<ArgumentError>(),
          predicate((dynamic e) =>
              e.message == 'The "error" parameter cannot take a StackTrace.'),
        ),
      ),
    );
  });
}
