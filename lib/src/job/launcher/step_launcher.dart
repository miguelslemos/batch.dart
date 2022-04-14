// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/batch.dart';
import 'package:batch/src/job/launcher/launcher.dart';
import 'package:batch/src/job/launcher/parallel_launcher.dart';
import 'package:batch/src/job/launcher/task_launcher.dart';

class StepLauncher extends Launcher<Step> {
  /// Returns the new instance of [StepLauncher].
  StepLauncher({
    required ExecutionContext context,
    required List<Step> steps,
    required String parentJobName,
  })  : assert(parentJobName.isNotEmpty),
        _steps = steps,
        super(context: context);

  /// The steps
  final List<Step> _steps;

  @override
  Future<void> run() async {
    for (final step in _steps) {
      await super.executeRecursively(
        event: step,
        execute: (step) async {
          if (step.task is Parallel) {
            await ParallelLauncher(
              context: context,
              parallel: step.task,
            ).run();
          } else {
            await TaskLauncher(
              context: context,
              task: step.task,
            ).run();
          }
        },
      );
    }
  }
}
