// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/parallel/parallel_executor.dart';
import 'package:batch/src/job/task/parallel_task.dart';

void main() {
  test('Test ParallelExecutor', () {
    final task = _ParallelTask();
    final executor =
        ParallelExecutor(parallelTask: task, context: ExecutionContext());

    expect(executor.parallelTask, task);
    expect(executor.instantiate(''), executor);
    expect(executor.parameters(), '');
    expect(() async => await executor.run(), returnsNormally);
  });

  test('Test ParallelExecutor with error', () {
    final task = _ParallelTaskWithError();
    final executor =
        ParallelExecutor(parallelTask: task, context: ExecutionContext());

    expect(executor.parallelTask, task);
    expect(executor.instantiate(''), executor);
    expect(executor.parameters(), '');
    expect(
        () async => await executor.run(),
        throwsA(allOf(isA<UnimplementedError>(),
            predicate((dynamic e) => e.message == 'success'))));
  });
}

class _ParallelTask extends ParallelTask<_ParallelTask> {
  @override
  FutureOr<void> execute(ExecutionContext context) {}
}

class _ParallelTaskWithError extends ParallelTask<_ParallelTaskWithError> {
  @override
  FutureOr<void> execute(ExecutionContext context) {
    throw UnimplementedError('success');
  }
}
