// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/diagnostics/boot_diagnostics.dart';
import 'package:batch/src/job/builder/scheduled_job_builder.dart';
import 'package:batch/src/job/config/retry_configuration.dart';
import 'package:batch/src/job/config/skip_configuration.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/error/unique_constraint_error.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/scheduled_job.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/schedule/parser/cron_parser.dart';
import 'package:batch/src/job/task/task.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

class _TestJob1Builder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [Step(name: 'Step', task: TestTask())],
      );
}

class _TestJob2Builder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(
            name: 'Step',
            task: TestTask(),
            branchesOnCompleted: [
              Step(name: 'Step2', task: TestTask()),
            ],
          )
        ],
        branchesOnCompleted: [
          Job(name: 'Job2', steps: [
            Step(name: 'Step', task: TestTask()),
          ])
        ],
      );
}

class _TestJob3Builder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(
            name: 'Step',
            task: TestTask(),
            skipConfig: SkipConfiguration(
              skippableExceptions: [],
            ),
          )
        ],
      );
}

class _TestJob4Builder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(
            name: 'Step',
            task: TestTask(),
            retryConfig: RetryConfiguration(
              retryableExceptions: [],
            ),
          ),
        ],
      );
}

class _TestJobWithoutStepBuilder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [],
      );
}

class _TestJobWithSkipAndRetryConfigsBuilder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(
            name: 'Step',
            task: TestTask(),
            skipConfig: SkipConfiguration(skippableExceptions: []),
            retryConfig: RetryConfiguration(retryableExceptions: []),
          )
        ],
      );
}

class _TestJobWithDuplicatedStepNamesBuilder extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(name: 'Step', task: TestTask()),
          Step(name: 'Step', task: TestTask()),
        ],
      );
}

class _TestJobWithDuplicatedStepNamesOnBranchBuilder
    extends ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Job',
        schedule: CronParser('* * * * *'),
        steps: [
          Step(
            name: 'Step',
            task: TestTask(),
            branchesOnCompleted: [
              Step(name: 'Step', task: TestTask()),
            ],
          )
        ],
      );
}

void main() {
  //! Required to load logger to run BootDiagnostics.
  Logger.loadFromConfig(LogConfiguration(printLog: false));

  group('Test when the application can be started', () {
    test('Test BootDiagnostics', () {
      final diagnostics = BootDiagnostics([_TestJob1Builder()]);
      expect(() => diagnostics.execute(), returnsNormally);
    });

    test('Test BootDiagnostics with branches', () {
      final diagnostics = BootDiagnostics([_TestJob2Builder()]);
      expect(() => diagnostics.execute(), returnsNormally);
    });

    test('Test BootDiagnostics with Skip config', () {
      final diagnostics = BootDiagnostics([_TestJob3Builder()]);
      expect(() => diagnostics.execute(), returnsNormally);
    });

    test('Test BootDiagnostics with Retry config', () {
      final diagnostics = BootDiagnostics([_TestJob4Builder()]);
      expect(() => diagnostics.execute(), returnsNormally);
    });
  });

  group('Test when the application can not be started', () {
    test('Test when there is no Job', () {
      expect(
        () => BootDiagnostics([]).execute(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) => e.message == 'The job to be launched is required.',
          ),
        )),
      );
    });

    test('Test when there is no Step', () {
      expect(
        () => BootDiagnostics([_TestJobWithoutStepBuilder()]).execute(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) => e.message == 'The step to be launched is required.',
          ),
        )),
      );
    });

    test('Test when Step has Skip and Retry configs', () {
      expect(
        () => BootDiagnostics([_TestJobWithSkipAndRetryConfigsBuilder()])
            .execute(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) =>
                e.message ==
                'You cannot set Skip and Retry at the same time in Step [name=Step].',
          ),
        )),
      );
    });

    test('Test when there is duplicated Step name', () {
      expect(
        () => BootDiagnostics([_TestJobWithDuplicatedStepNamesBuilder()])
            .execute(),
        throwsA(allOf(
          isA<UniqueConstraintError>(),
          predicate(
            (dynamic e) =>
                e.message ==
                'The name relations between Job and Step must be unique: [duplicatedRelation=[job=Job, step=Step]].',
          ),
        )),
      );
    });

    test('Test when there is duplicated Step name on branch', () {
      expect(
        () =>
            BootDiagnostics([_TestJobWithDuplicatedStepNamesOnBranchBuilder()])
                .execute(),
        throwsA(allOf(
          isA<UniqueConstraintError>(),
          predicate(
            (dynamic e) =>
                e.message ==
                'The name relations between Job and Step must be unique: [duplicatedRelation=[job=Job, step=Step]].',
          ),
        )),
      );
    });
  });
}

class TestTask extends Task<TestTask> {
  @override
  void execute(ExecutionContext context) {}
}
