// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/execution.dart';
import 'package:batch/src/job/execution_type.dart';
import 'package:batch/src/job/parameter/shared_parameters.dart';

void main() {
  test('Test without parameters', () {
    final context = ExecutionContext();
    expect(context.jobExecution, null);
    expect(context.stepExecution, null);
    expect(context.sharedParameters, SharedParameters.instance);
    expect(context.jobParameters.isEmpty, true);
  });

  test('Test with executions', () {
    final context = ExecutionContext();
    final now = DateTime.now();
    context.jobExecution =
        Execution(type: ExecutionType.job, name: 'Job', startedAt: now);
    context.stepExecution =
        Execution(type: ExecutionType.step, name: 'Step', startedAt: now);

    expect(context.jobExecution!.name, 'Job');
    expect(context.stepExecution!.name, 'Step');
    expect(context.sharedParameters, SharedParameters.instance);
    expect(context.jobParameters.isEmpty, true);
  });

  test('Test with sharedParameters', () {
    final context = ExecutionContext();
    expect(context.sharedParameters, SharedParameters.instance);
    expect(context.sharedParameters.isEmpty, true);
    expect(context.sharedParameters.isNotEmpty, false);

    context.sharedParameters['test'] = true;

    expect(context.sharedParameters.isEmpty, false);
    expect(context.sharedParameters.isNotEmpty, true);
    expect(context.sharedParameters['test'], true);
  });

  test('Test with jobParameters', () {
    final context = ExecutionContext();
    expect(context.jobParameters != context.sharedParameters, true);
    expect(context.jobParameters.isEmpty, true);
    expect(context.jobParameters.isNotEmpty, false);

    context.jobParameters['test'] = true;

    expect(context.jobParameters.isEmpty, false);
    expect(context.jobParameters.isNotEmpty, true);
    expect(context.jobParameters['test'], true);
  });
}
