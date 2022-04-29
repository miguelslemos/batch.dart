// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/batch.dart';
import 'package:batch/src/job/event/base_step.dart';

/// It represents the step responsible for parallel processing.
///
/// It has multiple [tasks] that are processed in parallel, with a maximum number
/// of parallelism equal to the number of [tasks].
class ParallelStep extends BaseStep {
  /// Returns the new instance of [ParallelStep].
  ParallelStep({
    required String name,
    required List<ParallelTask> tasks,
    FutureOr<bool> Function(ExecutionContext context)? precondition,
    Function(ExecutionContext context)? onStarted,
    Function(ExecutionContext context)? onSucceeded,
    Function(ExecutionContext context, dynamic error, StackTrace stackTrace)?
        onError,
    Function(ExecutionContext context)? onCompleted,
    SkipConfiguration? skipConfig,
    RetryConfiguration? retryConfig,
    List<BaseStep> branchesOnSucceeded = const [],
    List<BaseStep> branchesOnFailed = const [],
    List<BaseStep> branchesOnCompleted = const [],
  }) : super(
          name: name,
          tasks: tasks,
          precondition: precondition,
          onStarted: onStarted,
          onError: onError,
          onSucceeded: onSucceeded,
          onCompleted: onCompleted,
          skipConfig: skipConfig,
          retryConfig: retryConfig,
          branchesOnSucceeded: branchesOnSucceeded,
          branchesOnFailed: branchesOnFailed,
          branchesOnCompleted: branchesOnCompleted,
        );
}
