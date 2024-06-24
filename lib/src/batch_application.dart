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
import 'package:batch/src/job/builder/scheduled_job_builder.dart';
import 'package:batch/src/job/parameter/shared_parameters.dart';
import 'package:batch/src/job/schedule/job_scheduler.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';
import 'package:batch/src/log/logger_provider.dart';

/// The main entry point of the batch application.
///
/// Schedules [jobs] passed as arguments and starts long-lived server-side processes.
/// This [jobs] specification is required, and an exception will always be raised
/// if the job to be scheduled does not exist.
///
/// You can also set parameters in [shredParameters] that can be shared by all layers
/// of this application. This specification is useful for setting up data or singleton instances
/// that you want to share with all jobs.
///
/// If you wish to use command line arguments in the life cycle of a batch application,
/// pass command line arguments as arguments [args]. Also, the argument [argsConfigBuilder]
/// is always required when argument [args] is specified. The `argsConfigBuilder` is a
/// function for setting rules to parse [args] of type `List<String>` into a more manageable format,
/// allowing you to use the well-known [args](https://pub.dev/packages/args) library specification as is.
///
/// In addition, a possible use case for command line arguments is to use command line arguments
/// to create a singleton instance at the start of an application. In this [onLoadArgs] function,
/// [ArgsResult](https://pub.dev/documentation/args/latest/args/ArgResults-class.html)
/// parsed [args] according to the rules specified in [argsConfigBuilder] is passed
/// in the callback.
///
/// Now all that remains is to return a Map with arbitrary keys and values using
/// the data set in this [ArgsResult](https://pub.dev/documentation/args/latest/args/ArgResults-class.html).
/// Only the data in this returned map will be registered as `SharedParameters`,
/// and any command line arguments not specified in this map will be ignored.
///
/// **You can see more details at [Pub.dev](https://pub.dev/packages/batch/example)
/// or [official examples](https://github.com/batch-dart/examples/blob/main/README.md).**
void runWorkflow({
  List<String> args = const [],
  FutureOr<void> Function(ArgParser parser)? argsConfigBuilder,
  FutureOr<Map<String, dynamic>> Function(ArgResults args)? onLoadArgs,
  required List<ScheduledJobBuilder> jobs,
  Map<String, dynamic> sharedParameters = const {},
  LogConfiguration? logConfig,
}) =>
    // TODO:The following lines should be removed after making the BatchApplication class private.
// ignore: deprecated_member_use_from_same_package
    BatchApplication(
      args: args,
      argsConfigBuilder: argsConfigBuilder,
      onLoadArgs: onLoadArgs,
      jobs: jobs,
      sharedParameters: sharedParameters,
      logConfig: logConfig,
    )..run();

@Deprecated(
    'This class will be private in the future. Use runWorkflow instead.')
abstract class BatchApplication {
  /// Returns the new instance of [BatchApplication].
  factory BatchApplication({
    List<String> args = const [],
    FutureOr<void> Function(ArgParser parser)? argsConfigBuilder,
    FutureOr<Map<String, dynamic>> Function(ArgResults args)? onLoadArgs,
    required List<ScheduledJobBuilder> jobs,
    Map<String, dynamic> sharedParameters = const {},
    LogConfiguration? logConfig,
  }) =>
      _BatchApplication(
        args: args,
        argsConfigBuilder: argsConfigBuilder,
        onLoadArgs: onLoadArgs,
        jobs: jobs,
        sharedParameters: sharedParameters,
        logConfig: logConfig,
      );

  void run();
}

// TODO: The following lines should be removed after making the BatchApplication class private.
// ignore: deprecated_member_use_from_same_package
class _BatchApplication implements BatchApplication {
  /// Returns the new instance of [_BatchApplication].
  _BatchApplication({
    List<String> args = const [],
    FutureOr<void> Function(ArgParser parser)? argsConfigBuilder,
    FutureOr<Map<String, dynamic>> Function(ArgResults args)? onLoadArgs,
    required List<ScheduledJobBuilder> jobs,
    Map<String, dynamic> sharedParameters = const {},
    LogConfiguration? logConfig,
  })  : _args = args,
        _argsConfigBuilder = argsConfigBuilder,
        _onLoadArgs = onLoadArgs,
        _scheduledJobBuilders = jobs,
        _sharedParameters = sharedParameters,
        _logConfig = logConfig;

  /// The args
  final List<String> _args;

  /// The builder for argument configuration.
  final FutureOr<void> Function(ArgParser parser)? _argsConfigBuilder;

  /// The callback to be called when the commend line arguments are loaded.
  final FutureOr<Map<String, dynamic>> Function(ArgResults args)? _onLoadArgs;

  /// The job builders
  final List<ScheduledJobBuilder> _scheduledJobBuilders;

  /// The initial shared parameters
  final Map<String, dynamic> _sharedParameters;

  /// The configuration for logging
  final LogConfiguration? _logConfig;

  @override
  void run() async {
    if (!BatchInstance.isPending) {
      throw StateError('The batch application is already running.');
    }

    if (_args.isNotEmpty && _argsConfigBuilder == null) {
      throw StateError('''\n
        The command line arguments are specified, but the builder for argument configuration is not specified.
        Please specify the builder for argument configuration by using "argsConfigBuilder".
      ''');
    }

    BatchInstance.updateStatus(BatchStatus.starting);

    try {
      //! The logging functionality provided by the batch library
      //! will be available when this loading process is complete.
      Logger.loadFromConfig(_logConfig ?? LogConfiguration());

      log.info('🚀🚀🚀🚀🚀🚀🚀 The batch process has started! 🚀🚀🚀🚀🚀🚀🚀');
      log.info('Logger instance has completed loading');

      await _loadSharedParameters();

      JobScheduler(BootDiagnostics(_scheduledJobBuilders).execute()).run();
    } catch (e, s) {
      Logger.instance.dispose();
      print(s);
      throw Exception(e);
    }
  }

  Future<void> _loadSharedParameters() async {
    SharedParameters.instance.addAll(_sharedParameters);

    if (_args.isNotEmpty) {
      final parsedArgs = await _buildArgParser();

      if (_onLoadArgs != null) {
        final parameters = await _onLoadArgs!.call(parsedArgs);
        for (final key in parameters.keys) {
          SharedParameters.instance[key] = parameters[key];
        }
      } else {
        log.info('Add all command line arguments as SharedParameters');

        for (final option in parsedArgs.options) {
          SharedParameters.instance[option] = parsedArgs[option];
        }
      }
    }
  }

  Future<ArgResults> _buildArgParser() async {
    final argParser = ArgParser();
    await _argsConfigBuilder?.call(argParser);
    return argParser.parse(_args);
  }
}
