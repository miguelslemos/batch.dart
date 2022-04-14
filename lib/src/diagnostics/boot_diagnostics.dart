// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/diagnostics/name_relation.dart';
import 'package:batch/src/diagnostics/name_relations.dart';
import 'package:batch/src/job/error/unique_constraint_error.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/log/logger_provider.dart';
import 'package:batch/src/runner.dart';

abstract class BootDiagnostics implements Runner {
  /// Returns the new instance of [BootDiagnostics].
  factory BootDiagnostics({required List<Job> jobs}) =>
      _BootDiagnostics(jobs: jobs);
}

class _BootDiagnostics implements BootDiagnostics {
  /// Returns the new instance of [_BootDiagnostics].
  _BootDiagnostics({required List<Job> jobs}) : _jobs = jobs;

  /// The jobs
  final List<Job> _jobs;

  /// The name relations
  final _nameRelations = NameRelations();

  @override
  Future<void> run() async {
    log.info('Batch application diagnostics have been started');

    if (_jobs.isEmpty) {
      throw ArgumentError('The job to be launched is required.');
    }

    for (final job in _jobs) {
      if (job.isNotScheduled) {
        throw ArgumentError('Be sure to specify a schedule for the root job.');
      }

      _checkJobRecursively(job: job);
    }

    log.info('Batch application diagnostics have been completed');
    log.info('Batch applications can be started securely');
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

  void _checkStepRecursively({required Job job, required Step step}) {
    if (!step.hasTask) {
      throw ArgumentError(
        'The task or parallel to be launched is required.',
      );
    }

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
