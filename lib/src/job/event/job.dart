// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/event.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/schedule/parser/schedule_parser.dart';

/// This class represents a job which is the largest unit in batch execution processing.
///
/// Pass a unique [name] and a [cron] that represents the execution schedule
/// to the constructor when initializing [Job]. And then use the [nextStep] method
/// to add the [Step] to be executed.
class Job extends Event<Job> {
  /// Returns the new instance of [Job].
  Job({
    required String name,
    this.schedule,
    FutureOr<bool> Function(ExecutionContext context)? precondition,
    Function(ExecutionContext context)? onStarted,
    Function(ExecutionContext context)? onSucceeded,
    Function(ExecutionContext context, dynamic error, StackTrace stackTrace)?
        onError,
    Function(ExecutionContext context)? onCompleted,
  }) : super(
          name: name,
          precondition: precondition,
          onStarted: onStarted,
          onError: onError,
          onSucceeded: onSucceeded,
          onCompleted: onCompleted,
        );

  /// The schedule
  final ScheduleParser? schedule;

  /// The steps
  final List<Step> _steps = [];

  /// Returns the copied steps.
  List<Step> get steps => List.from(_steps);

  /// Adds [Step].
  ///
  /// Steps added by this [nextStep] method are executed in the order in which they are stored.
  ///
  /// Also the name of the Step must be unique, and an exception will be raised
  /// if a Step with a duplicate name has already been registered in this Job.
  void nextStep(final Step step) => _steps.add(step);

  /// Returns true if this job is not scheduled, otherwise false.
  bool get isNotScheduled => schedule == null;
}
