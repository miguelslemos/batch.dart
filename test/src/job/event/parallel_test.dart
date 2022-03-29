// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/event/parallel.dart';
import 'package:batch/src/job/task/parallel_task.dart';

void main() {
  test('Test Parallel', () {
    final task = _ParallelTask();
    final parallel = Parallel(
      name: 'Test Parallel',
      tasks: [task, task, task, task],
    );

    expect(parallel.name, 'Test Parallel');
    expect(parallel.executors.length, 4);

    for (final executor in parallel.executors) {
      expect(executor.parallelTask, task);
    }
  });

  test('Test unsupported features', () {
    final parallel = Parallel(name: 'Test Parallel', tasks: [_ParallelTask()]);

    expect(
        // ignore: deprecated_member_use_from_same_package
        () => parallel.branchOnSucceeded(
            to: Parallel(name: 'deprecated test', tasks: [])),
        throwsA(allOf(
            isA<UnsupportedError>(),
            predicate((dynamic e) =>
                e.message ==
                'Branch feature is not supported for parallel.'))));

    expect(
        // ignore: deprecated_member_use_from_same_package
        () => parallel.branchOnFailed(
            to: Parallel(name: 'deprecated test', tasks: [])),
        throwsA(allOf(
            isA<UnsupportedError>(),
            predicate((dynamic e) =>
                e.message ==
                'Branch feature is not supported for parallel.'))));

    expect(
        // ignore: deprecated_member_use_from_same_package
        () => parallel.branchOnCompleted(
            to: Parallel(name: 'deprecated test', tasks: [])),
        throwsA(allOf(
            isA<UnsupportedError>(),
            predicate((dynamic e) =>
                e.message ==
                'Branch feature is not supported for parallel.'))));
  });
}

class _ParallelTask extends ParallelTask<_ParallelTask> {
  @override
  FutureOr<void> invoke() {}
}
