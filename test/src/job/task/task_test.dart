// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

// Project imports:
import 'package:batch/src/batch_instance.dart';
import 'package:batch/src/batch_status.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/execution.dart';
import 'package:batch/src/job/execution_type.dart';
import 'package:batch/src/job/task/task.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  test('Test Task', () async {
    final task = _Task();

    final context = ExecutionContext();
    context.jobExecution = Execution(
        type: ExecutionType.job, name: 'test', startedAt: DateTime.now());
    expect(() => task.execute(context), returnsNormally);
  });
}

class _Task extends Task<_Task> {
  @override
  void execute(ExecutionContext context) {
    expect(context.jobExecution != null, true);
    expect(context.jobExecution!.name, 'test');

    BatchInstance.updateStatus(BatchStatus.running);
    expect(BatchInstance.isRunning, true);

    //! Required to load to run super.shutdown().
    Logger.loadFromConfig(LogConfiguration(printLog: false));

    expect(() => super.shutdown(), returnsNormally);
    expect(BatchInstance.isRunning, false);
    expect(BatchInstance.isShuttingDown, true);
  }
}
