// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:args/args.dart';

// Project imports:
import 'package:batch/src/batch_instance.dart';
import 'package:batch/src/batch_status.dart';
import 'package:batch/src/diagnostics/boot_diagnostics.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/parameter/shared_parameters.dart';
import 'package:batch/src/job/schedule/job_scheduler.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';
import 'package:batch/src/log/logger_provider.dart';
import 'package:batch/src/runner.dart';

/// This is a batch application that manages the execution of arbitrarily defined jobs
/// with own lifecycle.
///
/// In order to run this batch application, you first need to create at least
/// one [Job] object. After creating the Job object, use the [addJob] method to register
/// the Job to the batch application.
///
/// [Job] represents the maximum unit of a certain processing system
/// that consists of multiple steps. In addition, a Step consists of multiple Tasks. Step
/// is an intermediate concept between Job and Task, and Task is the specific
/// minimum unit of processing in a particular processing system.
///
/// You can use [addSharedParameter] to add a value that will be shared by the
/// entire this batch application. This value can be added by tying it to string key and
/// can be used in the Task class throughout the execution context.
///
/// Also you can get more information about implementation on
/// [example page](https://github.com/batch-dart/batch.dart/blob/main/example/example.dart).
///
/// These job configuration can be assembled in any way you like. For example,
/// you can configure it as follows.
///
/// ```
/// BatchApplication
/// │
/// │              ┌ Task1
/// │      ┌ Step1 ├ Task2
/// │      │       └ Task3
/// │      │
/// │      │       ┌ Task1
/// ├ Job1 ├ Step2 ├ Task2
/// │      │       └ Task3
/// │      │
/// │      │       ┌ Task1
/// │      └ Step3 ├ Task2
/// │              └ Task3
/// │
/// │              ┌ Task1
/// │      ┌ Step1 ├ Task2
/// │      │       └ ┄
/// │      │
/// │      │       ┌ Task1
/// └ Job2 ├ Step2 ├ ┄
///        │       └ ┄
///        │
///        │
///        └ ┄
/// ```
abstract class BatchApplication implements Runner {
  /// Returns the new instance of [BatchApplication].
  factory BatchApplication({
    ArgResults? args,
    LogConfiguration? logConfig,
    FutureOr<void> Function(
            ArgResults? args,
            void Function({
      required String key,
      required dynamic value,
    })
                addSharedParameter)?
        onLoadArgs,
  }) =>
      _BatchApplication(
        args: args,
        logConfig: logConfig,
        onLoadArgs: onLoadArgs,
      );

  /// Adds [Job].
  void addJob(final Job job);

  /// Adds parameter as global scope.
  void addSharedParameter({
    required String key,
    required dynamic value,
  });
}

class _BatchApplication implements BatchApplication {
  /// Returns the new instance of [_BatchApplication].
  _BatchApplication({
    ArgResults? args,
    LogConfiguration? logConfig,
    FutureOr<void> Function(
            ArgResults? args,
            Function({
      required String key,
      required dynamic value,
    })
                addSharedParameter)?
        onLoadArgs,
  })  : _args = args,
        _logConfig = logConfig,
        _onLoadArgs = onLoadArgs;

  /// The parsed args
  final ArgResults? _args;

  /// The configuration for logging
  final LogConfiguration? _logConfig;

  /// The callback to be called when the commend line arguments are loaded.
  final FutureOr<void> Function(
      ArgResults? args,
      void Function({
    required String key,
    required dynamic value,
  })
          addSharedParameter)? _onLoadArgs;

  /// The jobs
  final _jobs = <Job>[];

  @override
  void addJob(final Job job) => _jobs.add(job);

  @override
  void addSharedParameter({
    required String key,
    required dynamic value,
  }) =>
      SharedParameters.instance[key] = value;

  @override
  Future<void> run() async {
    if (!BatchInstance.isPending) {
      throw StateError(
          'This batch application has already been executed from the "run()" method. Multiple launches of batch applications are not allowed.');
    }

    BatchInstance.updateStatus(BatchStatus.starting);

    try {
      //! The logging functionality provided by the batch library
      //! will be available when this loading process is complete.
      Logger.loadFrom(config: _logConfig ?? LogConfiguration());

      info('🚀🚀🚀🚀🚀🚀🚀 The batch process has started! 🚀🚀🚀🚀🚀🚀🚀');
      info('Logger instance has completed loading');

      await BootDiagnostics(jobs: _jobs).run();

      if (_onLoadArgs != null) {
        await _onLoadArgs!.call(_args, addSharedParameter);
      } else {
        //! Add all arguments as SharedParameters if onLoad is not defined.
        if (_args != null) {
          log.info('Add all command line arguments as SharedParameters');

          for (final option in _args!.options) {
            addSharedParameter(key: option, value: _args![option]);
          }
        }
      }

      await JobScheduler(jobs: _jobs).run();
    } catch (e) {
      Logger.instance.dispose();
      throw Exception(e);
    }
  }
}
