// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/task.dart';
import 'package:batch/src/job/launcher/launcher.dart';

class TaskLauncher extends Launcher<Task> {
  /// Returns the new instance of [TaskLauncher].
  TaskLauncher({
    required ExecutionContext context,
    required Task task,
  })  : _task = task,
        super(context: context);

  /// The task
  final Task _task;

  @override
  Future<void> run() async => await super.executeRecursively(
        event: _task,
        execute: (task) async => await task.execute(context),
      );
}
