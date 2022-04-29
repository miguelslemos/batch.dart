// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:async_task/async_task.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/base_step.dart';
import 'package:batch/src/job/event/parallel_step.dart';
import 'package:batch/src/job/launcher/launcher.dart';
import 'package:batch/src/job/parallel/parallel_executor.dart';
import 'package:batch/src/log/logger_provider.dart';

class ParallelStepLauncher extends Launcher<BaseStep> {
  /// Returns the new instance of [ParallelStepLauncher].
  ParallelStepLauncher({
    required ExecutionContext context,
    required ParallelStep step,
  })  : _step = step,
        super(context: context);

  /// The parallel step
  final ParallelStep _step;

  Future<void> run() async => await super.executeRecursively(
        event: _step,
        execute: (step) async {
          final executors = _buildExecutor(step.tasks);

          final asyncExecutor = AsyncExecutor(
            parallelism: executors.length,
            taskTypeRegister: () => executors,
            logger: (String type, dynamic message,
                    [dynamic error, dynamic stackTrace]) =>
                log.info(message),
          );

          asyncExecutor.logger.enabled = true;

          try {
            final executions = asyncExecutor.executeAll(executors);
            await Future.wait(executions);

            for (final executor in executors) {
              for (final isolatedMessage in executor.result!) {
                isolatedMessage.output();
              }
            }
          } finally {
            await asyncExecutor.close();
          }
        },
      );

  List<ParallelExecutor> _buildExecutor(final List<dynamic> tasks) {
    final executors = <ParallelExecutor>[];
    for (final task in tasks) {
      executors.add(
        ParallelExecutor(
          parallelTask: task,
          context: context,
        ),
      );
    }

    return executors;
  }
}
