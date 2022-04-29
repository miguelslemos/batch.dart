// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/batch_instance.dart';
import 'package:batch/src/batch_status.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/log/logger_provider.dart';

/// This abstract class represents the smallest unit of processing that is
/// included in the steps when a job is executed.
///
/// The processing of each step of the job should be defined by overriding
/// [execute] in a class that inherits from this [Task].
abstract class Task<T extends Task<T>> {
  /// Runs this [Task].
  FutureOr<void> execute(final ExecutionContext context);

  /// Shutdown this batch application safely.
  void shutdown() {
    BatchInstance.updateStatus(BatchStatus.shuttingDown);
    log.warn(
        'The shutdown command was notified by Task: [name=${T.toString()}]');
  }
}
