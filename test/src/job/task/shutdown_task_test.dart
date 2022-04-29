// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/batch_instance.dart';
import 'package:batch/src/batch_status.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/task/shutdown_task.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  test('Test ShutdownTask', () {
    BatchInstance.updateStatus(BatchStatus.running);
    expect(BatchInstance.isRunning, true);

    //! Required to load logger to run Shutdown task.
    Logger.loadFromConfig(LogConfiguration(printLog: false));

    final task = ShutdownTask();
    expect(() => task.execute(ExecutionContext()), returnsNormally);
    expect(BatchInstance.isRunning, false);
    expect(BatchInstance.isShuttingDown, true);
  });
}
