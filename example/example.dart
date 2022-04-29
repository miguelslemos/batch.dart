// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

import 'dart:async';
import 'dart:io';

import 'package:batch/batch.dart';

void main(List<String> args) => runWorkflow(
      args: args,
      argsConfigBuilder: (parser) {
        // The well-known "args" library can be used as standard.
        // See more information about "args" at https://pub.dev/packages/args.
        parser
          ..addOption('userName', abbr: 'u')
          ..addOption('appName', abbr: 'a')
          ..addFlag('release', abbr: 'r', defaultsTo: false);
      },
      onLoadArgs: (args) {
        // This callback is useful when you want to create a singleton instance using command line arguments
        // and manage it as SharedParameters in batch application. If this callback is not defined,
        // all command line arguments are added as SharedParameters automatically.
        return {'userName': args['userName']};
      },
      jobs: [
        ///! You can add scheduled jobs here.
        _SayHelloWorldJob(),
        _TestRetryAndCallbackJob(),
        _TestBranchJob(),
        _ParallelJob(),
        _ShutdownJob()
      ],
      sharedParameters: {
        //! You can add any initial values and it's shared in this batch application.
        'token': 'xxxxxxxx',
        'tokens': ['xxxxxxxx', 'yyyyyyyy'],
      },
      logConfig: LogConfiguration(
        //! You can customize log configuration.
        level: LogLevel.trace,
        output: MultiLogOutput([
          ConsoleLogOutput(),
          FileLogOutput(file: File('./test.txt')),
        ]),
        color: LogColor(
          info: ConsoleColor.cyan3,
        ),
        printLog: true,
      ),
    );

class _SayHelloWorldJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Say Hello World Job',
        schedule: CronParser('*/1 * * * *'), //! Execute every minute.
        steps: [
          //! You can add steps.
          //! Please add in the order of execution.
          Step(name: 'Say Hello Step', task: SayHelloTask()),
          Step(name: 'Say World Step', task: SayWorldTask())
        ],
        jobParameters: {
          //! You can add any initial values and it's shared in this job.
          'token': 'xxxxxxxx',
          'tokens': ['xxxxxxxx', 'yyyyyyyy'],
        },
      );
}

class _TestRetryAndCallbackJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Test Retry Job',
        schedule: CronParser('*/1 * * * *'), //! Execute every 1 minutes.
        //! You can set any preconditions to run this job.
        steps: [
          Step(
            name: 'Test Retry and Callbacks Step',
            precondition: (context) => true,
            task: RetryTask(),
            //! You can use convenient callbacks to each cycle.
            onStarted: (context) => log.info('\n------ Started ------'),
            onSucceeded: (context) => log.info('\n------ Succeeded ------'),
            onError: (context, error, stackTrace) =>
                log.error('Something wrong!', error, stackTrace),
            onCompleted: (context) => log.info('\n------ Completed ------'),
            retryConfig: RetryConfiguration(
              maxAttempt: 3,
              backOff: Duration(seconds: 1),
              retryableExceptions: [FormatException()],
              onRecover: (context) {
                //! Do something when all retry attempts are failed.
              },
            ),
          ),
          Step(
            name: 'Test Skip Exception Step',
            task: SkipExceptionTask(),
            skipConfig: SkipConfiguration(skippableExceptions: [Exception()]),
          )
        ],
        precondition: (context) => true,
      );
}

class _TestBranchJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Test Branch Job',
        schedule: CronParser('*/2 * * * *'), //! Execute every 2 minutes.
        steps: [
          Step(
            name: 'Switch Branch Step',
            task: TestSwitchBranchTask(),
            branchesOnSucceeded: [
              Step(name: 'Say Hello Task (Branch)', task: SayHelloTask())
            ],
            branchesOnFailed: [
              Step(name: 'Should Not Be Executed Step', task: DummyTask())
            ],
            branchesOnCompleted: [
              Step(name: 'Say World Task (Branch)', task: SayWorldTask())
            ],
          )
        ],
      );
}

class _ParallelJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Parallel Job',
        schedule: CronParser('*/3 * * * *'), //! Execute every 5 minutes.
        steps: [
          ParallelStep(
            name: 'Parallel Step',
            precondition: (context) => true,
            tasks: [
              DoHeavyTask(),
              DoHeavyTask(),
              DoHeavyTask(),
              DoHeavyTask(),
            ],
          ),
        ],
      );
}

class _ShutdownJob implements ScheduledJobBuilder {
  @override
  ScheduledJob build() => ScheduledJob(
        name: 'Shutdown Job',
        schedule: CronParser('*/5 * * * *'), //! Execute every 5 minutes.
        steps: [
          Step.ofShutdown(),
        ],
      );
}

class TestTask extends Task<TestTask> {
  @override
  void execute(ExecutionContext context) {
    // This parameter is shared just in this job.
    context.jobParameters['key'] = 'job_parameter';

    // You can use shared parameters in any places.
    log.info(context.sharedParameters['key1']);
    log.info(context.sharedParameters['key2']);

    log.trace('Trace');
    log.info('Info');
    log.debug('Debug');
    log.warn('Warn');
    log.error('Error');
    log.fatal('Fatal');
  }
}

class SayHelloTask extends Task<SayHelloTask> {
  @override
  void execute(ExecutionContext context) {
    log.debug('Hello,');
  }
}

class SayWorldTask extends Task<SayWorldTask> {
  @override
  void execute(ExecutionContext context) {
    log.info('World!');
  }
}

class RetryTask extends Task<RetryTask> {
  /// The count for retry test
  static int count = 0;

  @override
  void execute(ExecutionContext context) {
    if (count < 3) {
      count++;
      throw FormatException();
    } else {
      count = 0;
    }
  }
}

class SkipExceptionTask extends Task<SkipExceptionTask> {
  @override
  void execute(ExecutionContext context) {
    throw Exception();
  }
}

class TestSwitchBranchTask extends Task<TestSwitchBranchTask> {
  @override
  void execute(ExecutionContext context) {
    // Switch branch on this step.
    context.stepExecution!.switchBranchToSucceeded();
  }
}

class DummyTask extends Task<DummyTask> {
  @override
  void execute(ExecutionContext context) {
    log.fatal('This should not be executed!.');
  }
}

class DoHeavyTask extends ParallelTask<DoHeavyTask> {
  @override
  FutureOr<void> execute(ExecutionContext context) {
    int i = 0;
    while (i < 10000000000) {
      i++;
    }

    //! The logging functions provided by frameworks such as "log.info" and "info" cannot be
    //! used in parallel processing. Instead, use the "sendMessage" method corresponding
    //! to the log level as below.
    //!
    //! Messages sent by the following "sendMessage" method are logged out at once after
    //! parallel processing is completed.
    super.sendMessageAsTrace('Trace');
    super.sendMessageAsDebug('Debug');
    super.sendMessageAsInfo('Info');

    try {
      throw Exception('Error output is also possible.');
    } catch (error, stackTrace) {
      // The error and stackTrace are optional.
      super.sendMessageAsWarn('Warn');
      super.sendMessageAsError('Error', error, stackTrace);
      super.sendMessageAsFatal('Fatal', error, stackTrace);
    }
  }
}
