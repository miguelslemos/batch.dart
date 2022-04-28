// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/config/retry_configuration.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/log/logger_provider.dart';

abstract class RetryPolicy {
  /// Returns the new instance of [RetryPolicy].
  factory RetryPolicy({required RetryConfiguration retryConfig}) =>
      _RetryPolicy(retryConfig: retryConfig);

  /// Waits for the specified duration.
  Future<void> wait();

  /// Returns true if [exception] passed as a parameter is a retryable, otherwise false.
  bool shouldRetry(final Exception exception);

  /// Returns true if [retryCount] is exceeded, otherwise false.
  bool isExceeded(final int retryCount);

  Future<void> recover(final ExecutionContext context);
}

/// The implementation class of [RetryPolicy].
class _RetryPolicy implements RetryPolicy {
  /// Returns the new instance of [_RetryPolicy].
  _RetryPolicy({required this.retryConfig});

  /// The retry configuration
  final RetryConfiguration retryConfig;

  @override
  Future<void> wait() async {
    if (retryConfig.backOff == null) {
      return;
    }

    log.warn('Wait [duration=${retryConfig.backOff}] before execute retry');
    await Future.delayed(retryConfig.backOff!);
  }

  @override
  bool shouldRetry(final Exception exception) => retryConfig.retryableExceptions
      .contains(exception.runtimeType.toString());

  @override
  bool isExceeded(final int retryCount) => retryCount >= retryConfig.maxAttempt;

  @override
  Future<void> recover(final ExecutionContext context) async {
    if (retryConfig.onRecover != null) {
      log.warn(
          'Recovery process is executed because the specified retry count limit has been reached.');
      await retryConfig.onRecover!.call(context);
    }
  }
}
