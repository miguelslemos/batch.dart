// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/diagnostics/name_relation.dart';
import 'package:batch/src/diagnostics/name_relations.dart';
import 'package:batch/src/job/builder/scheduled_job_builder.dart';
import 'package:batch/src/job/error/unique_constraint_error.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/scheduled_job.dart';
import 'package:batch/src/log/logger_provider.dart';

abstract class BootDiagnostics {
  /// Returns the new instance of [BootDiagnostics].
  factory BootDiagnostics(List<ScheduledJobBuilder> scheduledJobs) =>
      _BootDiagnostics(scheduledJobs: scheduledJobs);

  /// Returns the checked scheduled jobs.
  List<ScheduledJob> execute();
}

class _BootDiagnostics implements BootDiagnostics {
  /// Returns the new instance of [_BootDiagnostics].
  _BootDiagnostics({required List<ScheduledJobBuilder> scheduledJobs})
      : _scheduledJobs = scheduledJobs;

  /// The scheduled jobs
  final List<ScheduledJobBuilder> _scheduledJobs;

  /// The name relations
  final _nameRelations = NameRelations();

  @override
  List<ScheduledJob> execute() {
    log.info('Batch application diagnostics have been started');

    if (_scheduledJobs.isEmpty) {
      throw ArgumentError('The job to be launched is required.');
    }

    final scheduledJobs = <ScheduledJob>[];
    for (final job in _scheduledJobs) {
      final scheduledJob = job.build();
      scheduledJobs.add(scheduledJob);

      _checkJobRecursively(job: scheduledJob);
    }

    log.info('Batch application diagnostics have been completed');
    log.info('Batch applications can be started securely');

    return scheduledJobs;
  }

  void _checkJobRecursively({required Job job}) {
    if (job.steps.isEmpty) {
      throw ArgumentError('The step to be launched is required.');
    }

    for (final step in job.steps) {
      _checkStepRecursively(job: job, step: step);
    }

    if (job.hasBranch) {
      for (final branch in job.branches) {
        _checkJobRecursively(job: branch.to);
      }
    }
  }

  void _checkStepRecursively({required Job job, required dynamic step}) {
    if (step.hasSkipPolicy && step.hasRetryPolicy) {
      throw ArgumentError(
          'You cannot set Skip and Retry at the same time in Step [name=${step.name}].');
    }

    final relation = NameRelation(job: job.name, step: step.name);

    if (_nameRelations.has(relation)) {
      throw UniqueConstraintError(
          'The name relations between Job and Step must be unique: [duplicatedRelation=$relation].');
    }

    _nameRelations.add(relation);

    if (step.hasBranch) {
      for (final branch in step.branches) {
        _checkStepRecursively(job: job, step: branch.to);
      }
    }
  }
}
