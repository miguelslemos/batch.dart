// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/base_step.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/launcher/launcher.dart';

class StepLauncher extends Launcher<BaseStep> {
  /// Returns the new instance of [StepLauncher].
  StepLauncher({
    required ExecutionContext context,
    required Step step,
  })  : _step = step,
        super(context: context);

  /// The step
  final Step _step;

  Future<void> run() async => await super.executeRecursively(
        event: _step,
        execute: (step) async => await step.tasks.first.execute(context),
      );
}
