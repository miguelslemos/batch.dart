// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/task/parallel_task.dart';

void main() {
  test('Test ParallelTask', () {
    final task = _ParallelTask();
    final context = ExecutionContext();

    expect(() async => await task.execute(context), returnsNormally);
  });

  test('Test ParallelTask with error', () {
    final task = _ParallelTaskWithError();
    final context = ExecutionContext();

    expect(
        () async => await task.execute(context),
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
