// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/task/shutdown_task.dart';
import 'package:batch/src/job/task/task.dart';

void main() {
  test('Test Step with name parameter', () async {
    final step = Step(name: 'Step', task: _Task());
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
    final task = _Task();
    final step = Step(name: 'Step', task: task);
    expect(step.tasks.first, task);
  });

  test('Test shutdown', () {
    final step = Step.ofShutdown();
    expect(step.tasks.first is ShutdownTask, isTrue);
  });
}

class _Task extends Task<_Task> {
  @override
  void execute(ExecutionContext context) {}
}
