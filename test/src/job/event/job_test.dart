// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/schedule/parser/cron_parser.dart';

void main() {
  test('Test Job', () async {
    final job = Job(name: 'Job');
    expect(job.name, 'Job');
    expect(job.schedule, null);
    expect(job.isNotScheduled, true);
    expect(job.precondition, null);
    expect(job.onStarted, null);
    expect(job.onSucceeded, null);
    expect(job.onError, null);
    expect(job.onCompleted, null);
    expect(await job.shouldLaunch(ExecutionContext()), true);
    expect(job.hasBranch, false);
  });

  test('Test Job with schedule', () async {
    final job = Job(name: 'Job', schedule: CronParser(value: ''));
    expect(job.name, 'Job');
    expect(job.schedule != null, true);
    expect(job.isNotScheduled, false);
    expect(job.precondition, null);
    expect(job.onStarted, null);
    expect(job.onSucceeded, null);
    expect(job.onError, null);
    expect(job.onCompleted, null);
    expect(await job.shouldLaunch(ExecutionContext()), true);
    expect(job.hasBranch, false);
  });

  test('Test nextStep', () {
    final job = Job(name: 'Job');
    expect(job.name, 'Job');
    expect(job.steps.isEmpty, true);

    job.nextStep(Step(name: 'Step'));
    expect(job.steps.isEmpty, false);
    expect(job.steps.length, 1);
    expect(job.steps[0].name, 'Step');
  });
}
