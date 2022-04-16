// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/diagnostics/boot_diagnostics.dart';
import 'package:batch/src/job/config/retry_configuration.dart';
import 'package:batch/src/job/config/skip_configuration.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/error/unique_constraint_error.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/event/task.dart';
import 'package:batch/src/job/schedule/parser/cron_parser.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  //! Required to load logger to run BootDiagnostics.
  Logger.loadFrom(config: LogConfiguration(printLog: false));

  group('Test when the application can be started', () {
    test('Test BootDiagnostics', () {
      final diagnostics = BootDiagnostics(jobs: [
        Job(
          name: 'Job',
          schedule: CronParser(value: '* * * * *'),
        )..nextStep(
            Step(name: 'Step')..registerTask(TestTask()),
          ),
      ]);

      expect(() => diagnostics.run(), returnsNormally);
    });

    test('Test BootDiagnostics with branches', () {
      final diagnostics = BootDiagnostics(jobs: [
        Job(
          name: 'Job',
          schedule: CronParser(value: '* * * * *'),
        )
          ..nextStep(
            Step(name: 'Step')
              ..registerTask(TestTask())
              ..createBranchOnCompleted(
                to: Step(name: 'Step2')..registerTask(TestTask()),
              ),
          )
          ..createBranchOnCompleted(
            to: Job(name: 'Job2')
              ..nextStep(
                Step(name: 'Step')..registerTask(TestTask()),
              ),
          ),
      ]);

      expect(() => diagnostics.run(), returnsNormally);
    });

    test('Test BootDiagnostics with Skip config', () {
      final diagnostics = BootDiagnostics(jobs: [
        Job(
          name: 'Job',
          schedule: CronParser(value: '* * * * *'),
        )..nextStep(
            Step(
              name: 'Step',
              skipConfig: SkipConfiguration(
                skippableExceptions: [],
              ),
            )..registerTask(TestTask()),
          ),
      ]);

      expect(() => diagnostics.run(), returnsNormally);
    });

    test('Test BootDiagnostics with Retry config', () {
      final diagnostics = BootDiagnostics(jobs: [
        Job(
          name: 'Job',
          schedule: CronParser(value: '* * * * *'),
        )..nextStep(
            Step(
              name: 'Step',
              retryConfig: RetryConfiguration(
                retryableExceptions: [],
              ),
            )..registerTask(TestTask()),
          ),
      ]);

      expect(() => diagnostics.run(), returnsNormally);
    });
  });

  group('Test when the application can not be started', () {
    test('Test when there is no Job', () {
      expect(
        () => BootDiagnostics(jobs: []).run(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) => e.message == 'The job to be launched is required.',
          ),
        )),
      );
    });

    test('Test when there is no schedule on root Job', () {
      expect(
        () => BootDiagnostics(jobs: [Job(name: 'Job')]).run(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) =>
                e.message == 'Be sure to specify a schedule for the root job.',
          ),
        )),
      );
    });

    test('Test when there is no Step', () {
      expect(
        () => BootDiagnostics(jobs: [
          Job(
            name: 'Job',
            schedule: CronParser(value: '* * * * *'),
          )
        ]).run(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) => e.message == 'The step to be launched is required.',
          ),
        )),
      );
    });

    test('Test when there is no Task', () {
      expect(
        () => BootDiagnostics(jobs: [
          Job(
            name: 'Job',
            schedule: CronParser(value: '* * * * *'),
          )..nextStep(
              Step(name: 'Step'),
            )
        ]).run(),
        throwsA(allOf(
          isArgumentError,
          predicate(
            (dynamic e) =>
                e.message == 'The task or parallel to be launched is required.',
          ),
        )),
      );
    });

    test('Test when Step has Skip and Retry configs', () {
      expect(
        () => BootDiagnostics(jobs: [
          Job(
            name: 'Job',
            schedule: CronParser(value: '* * * * *'),
          )..nextStep(
              Step(
                name: 'Step',
                skipConfig: SkipConfiguration(skippableExceptions: []),
                retryConfig: RetryConfiguration(retryableExceptions: []),
              )..registerTask(TestTask()),
            )
        ]).run(),
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
        () => BootDiagnostics(jobs: [
          Job(name: 'Job', schedule: CronParser(value: '* * * * *'))
            ..nextStep(Step(name: 'Step')..registerTask(TestTask()))
            ..nextStep(Step(name: 'Step')..registerTask(TestTask()))
        ]).run(),
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
        () => BootDiagnostics(jobs: [
          Job(name: 'Job', schedule: CronParser(value: '* * * * *'))
            ..nextStep(Step(name: 'Step')
              ..registerTask(TestTask())
              ..createBranchOnCompleted(
                to: (Step(name: 'Step')..registerTask(TestTask())),
              ))
        ]).run(),
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
  TestTask({
    SkipConfiguration? skipConfig,
    RetryConfiguration? retryConfig,
  }) : super(skipConfig: skipConfig, retryConfig: retryConfig);

  @override
  void execute(ExecutionContext context) {}
}
