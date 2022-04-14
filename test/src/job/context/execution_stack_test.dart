// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/context/execution_stack.dart';
import 'package:batch/src/job/execution.dart';
import 'package:batch/src/job/execution_type.dart';

void main() {
  test('Test ExecutionStack', () {
    final stack = ExecutionStack();
    expect(stack.isEmpty, true);
    expect(stack.isNotEmpty, false);

    final executions = [
      Execution(
          type: ExecutionType.job, name: 'Test1', startedAt: DateTime.now()),
      Execution(
          type: ExecutionType.job, name: 'Test2', startedAt: DateTime.now()),
      Execution(
          type: ExecutionType.job, name: 'Test3', startedAt: DateTime.now()),
      Execution(
          type: ExecutionType.job, name: 'Test4', startedAt: DateTime.now())
    ];

    for (final execution in executions) {
      stack.push(execution);
    }

    expect(stack.isEmpty, false);
    expect(stack.isNotEmpty, true);

    for (int i = executions.length - 1; i >= 0; i--) {
      expect(stack.pop().name, executions[i].name);
    }

    expect(stack.isEmpty, true);
    expect(stack.isNotEmpty, false);
  });
}
