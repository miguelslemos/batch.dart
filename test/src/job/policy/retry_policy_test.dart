// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/batch.dart';
import 'package:batch/src/job/policy/retry_policy.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  test('Test RetryPolicy', () {
    final retryPolicy = RetryPolicy(
      retryConfig: RetryConfiguration(retryableExceptions: [FormatException()]),
    );

    expect(retryPolicy.shouldRetry(FormatException()), true);
    expect(retryPolicy.shouldRetry(_TestException()), false);
    expect(() async => await retryPolicy.wait(), returnsNormally);
  });
  test('Test RetryPolicy with back off', () {
    final duration = Duration(seconds: 3);
    final retryPolicy = RetryPolicy(
      retryConfig: RetryConfiguration(
        retryableExceptions: [FormatException()],
        backOff: duration,
        maxAttempt: 20,
      ),
    );

    //! Required to load to run wait() with back off.
    Logger.loadFromConfig(LogConfiguration(printLog: false));

    expect(retryPolicy.shouldRetry(FormatException()), true);
    expect(retryPolicy.shouldRetry(_TestException()), false);
    expect(retryPolicy.isExceeded(21), true);
    expect(retryPolicy.isExceeded(20), true);
    expect(retryPolicy.isExceeded(19), false);
    expect(() async => await retryPolicy.wait(), returnsNormally);
  });
}

class _TestException implements Exception {}
