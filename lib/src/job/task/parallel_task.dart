// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/task.dart';
import 'package:batch/src/job/parallel/parallel_task_support.dart';

abstract class ParallelTask<T extends Task<T>> extends Task<T>
    with ParallelTaskSupport {
  Future<void> invoke(ExecutionContext context) async {
    try {
      await execute(context);
    } catch (e) {
      rethrow;
    }

    // ignore: invalid_use_of_visible_for_overriding_member
    context.jobParameters['_internalIsolatedLogMessages'] = isolatedMessages;
  }
}
