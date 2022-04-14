// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/job/config/retry_configuration.dart';
import 'package:batch/src/job/config/skip_configuration.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/event.dart';
import 'package:batch/src/job/event/parallel.dart';
import 'package:batch/src/job/event/task.dart';
import 'package:batch/src/job/task/shutdown_task.dart';

/// This class represents the processing of each step that constitutes a job in batch processing.
class Step extends Event<Step> {
  /// Returns the new instance of [Step].
  Step({
    required String name,
    FutureOr<bool> Function(ExecutionContext context)? precondition,
    Function(ExecutionContext context)? onStarted,
    Function(ExecutionContext context)? onSucceeded,
    Function(ExecutionContext context, dynamic error, StackTrace stackTrace)?
        onError,
    Function(ExecutionContext context)? onCompleted,
    SkipConfiguration? skipConfig,
    RetryConfiguration? retryConfig,
  }) : super(
          name: name,
          precondition: precondition,
          onStarted: onStarted,
          onError: onError,
          onSucceeded: onSucceeded,
          onCompleted: onCompleted,
          skipConfig: skipConfig,
          retryConfig: retryConfig,
        );

  /// The task include parallel
  dynamic _task;

  /// Returns the copied task.
  dynamic get task => _task;

  /// Registers [Task].
  void registerTask(final Task task) => _task = task;

  /// Registers [Parallel].
  void registerParallel(final Parallel parallel) => _task = parallel;

  /// Registers a task to shutdown this application.
  void shutdown() => _task = ShutdownTask();

  /// Returns true if this step has a task, otherwise false.
  bool get hasTask => _task != null;
}
