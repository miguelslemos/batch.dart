// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/event/task.dart';

void main() {
  test('Test Step with name parameter', () async {
    final step = Step(name: 'Step');
    expect(step.name, 'Step');
    expect(step.precondition, null);
    expect(step.onStarted, null);
    expect(step.onSucceeded, null);
    expect(step.onError, null);
    expect(step.onCompleted, null);
    expect(step.skipPolicy, null);
    expect(step.retryPolicy, null);
    expect(step.hasSkipPolicy, false);
    expect(step.hasRetryPolicy, false);
    expect(await step.shouldLaunch(ExecutionContext()), true);
    expect(step.hasBranch, false);
  });

  test('Test nextTask', () {
    final step = Step(name: 'Step');
    expect(step.name, 'Step');
    expect(step.hasTask, isFalse);

    final task = _Task();
    step.registerTask(task);
    expect(step.hasTask, isTrue);
    expect(step.task, task);
  });

  test('Test shutdown', () {
    final step = Step(name: 'Step');
    expect(step.name, 'Step');
    expect(step.hasTask, isFalse);

    step.shutdown();
    expect(step.hasTask, isTrue);
    expect(step.task.name, 'ShutdownTask');
  });
}

class _Task extends Task<_Task> {
  @override
  void execute(ExecutionContext context) {}
}
