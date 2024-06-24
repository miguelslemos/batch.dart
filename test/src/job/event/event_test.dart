// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/config/retry_configuration.dart';
import 'package:batch/src/job/config/skip_configuration.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/event.dart';

void main() {
  test('Test Event with required parameter', () async {
    final event = _Event(name: 'eventName');
    expect(event.name, 'eventName');
    expect(event.precondition, null);
    expect(event.onStarted, null);
    expect(event.onSucceeded, null);
    expect(event.onError, null);
    expect(event.onCompleted, null);
    expect(event.skipPolicy, null);
    expect(event.retryPolicy, null);
    expect(event.hasSkipPolicy, false);
    expect(event.hasRetryPolicy, false);
    expect(await event.shouldLaunch(ExecutionContext()), true);
    expect(event.hasBranch, false);
  });

  test('Test Event with precondition', () async {
    final event = _Event(name: 'name', precondition: (context) => false);
    expect(event.name, 'name');
    expect(await event.shouldLaunch(ExecutionContext()), false);
  });

  test('Test Event with callbacks', () {
    final event = _Event(
      name: 'name',
      onStarted: (context) => true,
      onSucceeded: (context) => true,
      onError: (context, error, stackTrace) => true,
      onCompleted: (context) => true,
    );

    expect(event.name, 'name');
    expect(event.onStarted != null, true);
    expect(event.onSucceeded != null, true);
    expect(event.onError != null, true);
    expect(event.onCompleted != null, true);
  });

  test('Test Event with policies', () {
    final event = _Event(
      name: 'name',
      skipConfig: SkipConfiguration(skippableExceptions: []),
      retryConfig: RetryConfiguration(retryableExceptions: []),
    );

    expect(event.name, 'name');
    expect(event.skipPolicy != null, true);
    expect(event.retryPolicy != null, true);
  });

  test('Test Event with branches', () {
    final event = _Event(
      name: 'name',
      branchesOnSucceeded: [_Event(name: 'succeeded')],
      branchesOnFailed: [_Event(name: 'failed')],
      branchesOnCompleted: [_Event(name: 'completed')],
    );

    expect(event.name, 'name');
    expect(event.hasBranch, true);
    expect(event.branches.length, 3);
    expect(event.branches[0].on, BranchStatus.succeeded);
    expect(event.branches[0].to.name, 'succeeded');
    expect(event.branches[1].on, BranchStatus.failed);
    expect(event.branches[1].to.name, 'failed');
    expect(event.branches[2].on, BranchStatus.completed);
    expect(event.branches[2].to.name, 'completed');
  });
}

class _Event extends Event<_Event> {
  _Event({
    required String name,
    FutureOr<bool> Function(ExecutionContext context)? precondition,
    Function(ExecutionContext context)? onStarted,
    Function(ExecutionContext context)? onSucceeded,
    Function(ExecutionContext context, dynamic error, StackTrace stackTrace)?
        onError,
    Function(ExecutionContext context)? onCompleted,
    SkipConfiguration? skipConfig,
    RetryConfiguration? retryConfig,
    List<_Event> branchesOnSucceeded = const [],
    List<_Event> branchesOnFailed = const [],
    List<_Event> branchesOnCompleted = const [],
  }) : super(
          name: name,
          precondition: precondition,
          onStarted: onStarted,
          onError: onError,
          onSucceeded: onSucceeded,
          onCompleted: onCompleted,
          skipConfig: skipConfig,
          retryConfig: retryConfig,
          branchesOnSucceeded: branchesOnSucceeded,
          branchesOnFailed: branchesOnFailed,
          branchesOnCompleted: branchesOnCompleted,
        );
}
