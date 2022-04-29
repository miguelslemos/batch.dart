// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/base_step.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/schedule/parser/schedule_parser.dart';

/// This object represents the largest unit of events in the workflow.
///
/// This event must have multiple [steps] and the [schedule] is required. It is
/// similar to [Job], but differs in that it **may** or **may not** be scheduled.
///
/// In addition, the [ScheduledJob] event can set [jobParameters] parameters that are shared
/// in scope between [BaseStep]s associated with this [ScheduledJob]. This is a similar specification to
/// `SharedParameters`, except that the scope in which the parameters are shared is different.
class ScheduledJob extends Job {
  /// Returns the new instance of [ScheduledWorkflow].
  ScheduledJob({
    required String name,
    required this.schedule,
    required List<BaseStep> steps,
    Map<String, dynamic> jobParameters = const {},
    FutureOr<bool> Function(ExecutionContext context)? precondition,
    Function(ExecutionContext context)? onStarted,
    Function(ExecutionContext context)? onSucceeded,
    Function(ExecutionContext context, dynamic error, StackTrace stackTrace)?
        onError,
    Function(ExecutionContext context)? onCompleted,
    List<Job> branchesOnSucceeded = const [],
    List<Job> branchesOnFailed = const [],
    List<Job> branchesOnCompleted = const [],
  }) : super(
          name: name,
          steps: steps,
          jobParameters: jobParameters,
          precondition: precondition,
          onStarted: onStarted,
          onError: onError,
          onSucceeded: onSucceeded,
          onCompleted: onCompleted,
          branchesOnSucceeded: branchesOnSucceeded,
          branchesOnFailed: branchesOnFailed,
          branchesOnCompleted: branchesOnCompleted,
        );

  /// The schedule
  final ScheduleParser schedule;
}
