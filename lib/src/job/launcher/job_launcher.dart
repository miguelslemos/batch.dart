// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/parallel_step.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/launcher/launcher.dart';
import 'package:batch/src/job/launcher/parallel_step_launcher.dart';
import 'package:batch/src/job/launcher/step_launcher.dart';

/// This class provides the feature to securely execute registered jobs.
class JobLauncher extends Launcher<Job> {
  /// Returns the new instance of [JobLauncher].
  JobLauncher({
    required Job job,
  })  : _job = job,
        super(context: ExecutionContext());

  /// The job
  final Job _job;

  Future<void> run() async => await super.executeRecursively(
        event: _job,
        execute: (job) async {
          context.jobParameters.addAll(job.jobParameters);

          for (final step in job.steps) {
            if (step is Step) {
              await StepLauncher(
                context: context,
                step: step,
              ).run();
            } else if (step is ParallelStep) {
              await ParallelStepLauncher(
                context: context,
                step: step,
              ).run();
            } else {
              throw UnsupportedError('The step type is not supported.');
            }
          }

          //! Removes step job parameters set within the step executed last time.
          super.context.jobParameters.removeAll();
        },
      );
}
