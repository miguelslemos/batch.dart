// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/context/context_support.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/event/step.dart';
import 'package:batch/src/job/event/task.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  //! Required to load logger to run ContextSupport.
  Logger.loadFrom(config: LogConfiguration(printLog: false));

  group('Test ContextSupport for Job', () {
    test('Test when not a retry and complete', () {
      final contextSupport = _JobContextSupport();
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Job', retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, true);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt, null);
      expect(contextSupport.context.jobExecution!.finishedAt, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);

      // Try to change branch status.
      contextSupport.context.jobExecution!.switchBranchToSucceeded();
      expect(contextSupport.branchStatus, BranchStatus.succeeded);
      contextSupport.context.jobExecution!.switchBranchToFailed();
      expect(contextSupport.branchStatus, BranchStatus.failed);

      contextSupport.finishExecutionAsCompleted(retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, false);
      expect(contextSupport.context.jobExecution!.isCompleted, true);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt != null, true);
      expect(contextSupport.context.jobExecution!.finishedAt != null, true);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);
    });

    test('Test when a retry and skip', () {
      final contextSupport = _JobContextSupport();
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Job', retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, true);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt, null);
      expect(contextSupport.context.jobExecution!.finishedAt, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);

      // Try to change branch status.
      contextSupport.context.jobExecution!.switchBranchToSucceeded();
      expect(contextSupport.branchStatus, BranchStatus.succeeded);
      expect(contextSupport.context.jobExecution!.updatedAt != null, true);
      contextSupport.context.jobExecution!.switchBranchToFailed();
      expect(contextSupport.branchStatus, BranchStatus.failed);
      expect(contextSupport.context.jobExecution!.updatedAt != null, true);

      // Should skip create new and finish execution on retry
      contextSupport.startNewExecution(name: 'Job2', retry: true);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, true);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt != null, true);
      expect(contextSupport.context.jobExecution!.finishedAt, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.failed);
      contextSupport.finishExecutionAsCompleted(retry: true);
      expect(contextSupport.context.jobExecution!.name, 'Job');

      contextSupport.finishExecutionAsSkipped(retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, false);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, true);
      expect(contextSupport.context.jobExecution!.updatedAt != null, true);
      expect(contextSupport.context.jobExecution!.finishedAt != null, true);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);
    });
  });

  group('Test ContextSupport for Step', () {
    test('Test when not a retry and complete', () {
      final contextSupport = _StepContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Step', retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, true);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt, null);
      expect(contextSupport.context.stepExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);

      // Try to change branch status.
      contextSupport.context.stepExecution!.switchBranchToSucceeded();
      expect(contextSupport.branchStatus, BranchStatus.succeeded);
      contextSupport.context.stepExecution!.switchBranchToFailed();
      expect(contextSupport.branchStatus, BranchStatus.failed);

      contextSupport.finishExecutionAsCompleted(retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, false);
      expect(contextSupport.context.stepExecution!.isCompleted, true);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt != null, true);
      expect(contextSupport.context.stepExecution!.finishedAt != null, true);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.taskExecution, null);
    });

    test('Test when a retry and skip', () {
      final contextSupport = _StepContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Step', retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, true);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt, null);
      expect(contextSupport.context.stepExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);

      // Try to change branch status.
      contextSupport.context.stepExecution!.switchBranchToSucceeded();
      expect(contextSupport.branchStatus, BranchStatus.succeeded);
      expect(contextSupport.context.stepExecution!.updatedAt != null, true);
      contextSupport.context.stepExecution!.switchBranchToFailed();
      expect(contextSupport.branchStatus, BranchStatus.failed);
      expect(contextSupport.context.stepExecution!.updatedAt != null, true);

      // Should skip create new and finish execution on retry
      contextSupport.startNewExecution(name: 'Step2', retry: true);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, true);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt != null, true);
      expect(contextSupport.context.stepExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.taskExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.failed);
      contextSupport.finishExecutionAsCompleted(retry: true);
      expect(contextSupport.context.stepExecution!.name, 'Step');

      contextSupport.finishExecutionAsSkipped(retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, false);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, true);
      expect(contextSupport.context.stepExecution!.updatedAt != null, true);
      expect(contextSupport.context.stepExecution!.finishedAt != null, true);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.taskExecution, null);
    });
  });

  group('Test ContextSupport for Task', () {
    test('Test when not a retry and complete', () {
      final contextSupport = _TaskContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Task', retry: false);
      expect(contextSupport.context.taskExecution!.name, 'Task');
      expect(contextSupport.context.taskExecution!.isRunning, true);
      expect(contextSupport.context.taskExecution!.isCompleted, false);
      expect(contextSupport.context.taskExecution!.isSkipped, false);
      expect(contextSupport.context.taskExecution!.updatedAt, null);
      expect(contextSupport.context.taskExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);
    });

    test('Test when a retry and skip', () {
      final contextSupport = _TaskContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.context.taskExecution, null);

      contextSupport.startNewExecution(name: 'Task', retry: false);
      expect(contextSupport.context.taskExecution!.name, 'Task');
      expect(contextSupport.context.taskExecution!.isRunning, true);
      expect(contextSupport.context.taskExecution!.isCompleted, false);
      expect(contextSupport.context.taskExecution!.isSkipped, false);
      expect(contextSupport.context.taskExecution!.updatedAt, null);
      expect(contextSupport.context.taskExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);
      expect(contextSupport.branchStatus, BranchStatus.completed);
    });
  });

  group('Test ContextSupport for complex patterns', () {
    test('Test simple flow "Job → Step → Task" and not a retry', () {
      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);

      jobContextSupport.startNewExecution(name: 'Job', retry: false);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);

      {
        //! Step block
        final stepContextSupport =
            _StepContextSupport(context: jobContextSupport.context);
        expect(stepContextSupport.context.jobExecution != null, true);
        expect(stepContextSupport.context.stepExecution, null);
        expect(stepContextSupport.context.taskExecution, null);

        stepContextSupport.startNewExecution(name: 'Step', retry: false);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, true);
        expect(stepContextSupport.context.stepExecution!.isCompleted, false);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(stepContextSupport.context.stepExecution!.updatedAt, null);
        expect(stepContextSupport.context.stepExecution!.finishedAt, null);
        expect(stepContextSupport.context.taskExecution, null);
        expect(stepContextSupport.branchStatus, BranchStatus.completed);

        {
          //! Task block
          final taskContextSupport =
              _TaskContextSupport(context: stepContextSupport.context);
          expect(taskContextSupport.context.jobExecution != null, true);
          expect(taskContextSupport.context.stepExecution != null, true);
          expect(taskContextSupport.context.taskExecution, null);

          taskContextSupport.startNewExecution(name: 'Task', retry: false);
          //! Job
          expect(taskContextSupport.context.jobExecution!.name, 'Job');
          expect(taskContextSupport.context.jobExecution!.isRunning, true);
          expect(taskContextSupport.context.jobExecution!.isCompleted, false);
          expect(taskContextSupport.context.jobExecution!.isSkipped, false);
          expect(taskContextSupport.context.jobExecution!.updatedAt, null);
          expect(taskContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(taskContextSupport.context.stepExecution!.name, 'Step');
          expect(taskContextSupport.context.stepExecution!.isRunning, true);
          expect(taskContextSupport.context.stepExecution!.isCompleted, false);
          expect(taskContextSupport.context.stepExecution!.isSkipped, false);
          expect(taskContextSupport.context.stepExecution!.updatedAt, null);
          expect(taskContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(taskContextSupport.context.taskExecution!.name, 'Task');
          expect(taskContextSupport.context.taskExecution!.isRunning, true);
          expect(taskContextSupport.context.taskExecution!.isCompleted, false);
          expect(taskContextSupport.context.taskExecution!.isSkipped, false);
          expect(taskContextSupport.context.taskExecution!.updatedAt, null);
          expect(taskContextSupport.context.taskExecution!.finishedAt, null);
          expect(taskContextSupport.branchStatus, BranchStatus.completed);

          taskContextSupport.finishExecutionAsCompleted(retry: false);
          //! Job
          expect(stepContextSupport.context.jobExecution!.name, 'Job');
          expect(stepContextSupport.context.jobExecution!.isRunning, true);
          expect(stepContextSupport.context.jobExecution!.isCompleted, false);
          expect(stepContextSupport.context.jobExecution!.isSkipped, false);
          expect(stepContextSupport.context.jobExecution!.updatedAt, null);
          expect(stepContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(stepContextSupport.context.stepExecution!.name, 'Step');
          expect(stepContextSupport.context.stepExecution!.isRunning, true);
          expect(stepContextSupport.context.stepExecution!.isCompleted, false);
          expect(stepContextSupport.context.stepExecution!.isSkipped, false);
          expect(stepContextSupport.context.stepExecution!.updatedAt, null);
          expect(stepContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(stepContextSupport.context.taskExecution!.name, 'Task');
          expect(stepContextSupport.context.taskExecution!.isRunning, false);
          expect(stepContextSupport.context.taskExecution!.isCompleted, true);
          expect(stepContextSupport.context.taskExecution!.isSkipped, false);
          expect(stepContextSupport.context.taskExecution!.updatedAt != null,
              true);
          expect(stepContextSupport.context.taskExecution!.finishedAt != null,
              true);
        }

        stepContextSupport.finishExecutionAsCompleted(retry: false);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, false);
        expect(stepContextSupport.context.stepExecution!.isCompleted, true);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(
            stepContextSupport.context.stepExecution!.updatedAt != null, true);
        expect(
            stepContextSupport.context.stepExecution!.finishedAt != null, true);
        //! Task
        expect(stepContextSupport.context.taskExecution!.name, 'Task');
        expect(stepContextSupport.context.taskExecution!.isRunning, false);
        expect(stepContextSupport.context.taskExecution!.isCompleted, true);
        expect(stepContextSupport.context.taskExecution!.isSkipped, false);
        expect(
            stepContextSupport.context.taskExecution!.updatedAt != null, true);
        expect(
            stepContextSupport.context.taskExecution!.finishedAt != null, true);
      }

      jobContextSupport.finishExecutionAsCompleted(retry: false);
      //! Job
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, false);
      expect(jobContextSupport.context.jobExecution!.isCompleted, true);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.jobExecution!.finishedAt != null, true);
      //! Step
      expect(jobContextSupport.context.stepExecution!.name, 'Step');
      expect(jobContextSupport.context.stepExecution!.isRunning, false);
      expect(jobContextSupport.context.stepExecution!.isCompleted, true);
      expect(jobContextSupport.context.stepExecution!.isSkipped, false);
      expect(jobContextSupport.context.stepExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.stepExecution!.finishedAt != null, true);
      //! Task
      expect(jobContextSupport.context.taskExecution!.name, 'Task');
      expect(jobContextSupport.context.taskExecution!.isRunning, false);
      expect(jobContextSupport.context.taskExecution!.isCompleted, true);
      expect(jobContextSupport.context.taskExecution!.isSkipped, false);
      expect(jobContextSupport.context.taskExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.taskExecution!.finishedAt != null, true);
    });

    test('Test simple flow "Job → Step → Task" and a retry', () {
      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);

      jobContextSupport.startNewExecution(name: 'Job', retry: false);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);

      // Should skip create new and finish execution on retry
      jobContextSupport.startNewExecution(name: 'Job2', retry: true);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);
      jobContextSupport.finishExecutionAsSkipped(retry: true);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);

      {
        //! Step block
        final stepContextSupport =
            _StepContextSupport(context: jobContextSupport.context);
        expect(stepContextSupport.context.jobExecution != null, true);
        expect(stepContextSupport.context.stepExecution, null);
        expect(stepContextSupport.context.taskExecution, null);

        stepContextSupport.startNewExecution(name: 'Step', retry: false);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, true);
        expect(stepContextSupport.context.stepExecution!.isCompleted, false);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(stepContextSupport.context.stepExecution!.updatedAt, null);
        expect(stepContextSupport.context.stepExecution!.finishedAt, null);
        expect(stepContextSupport.context.taskExecution, null);
        expect(stepContextSupport.branchStatus, BranchStatus.completed);

        // Should skip create new and finish execution on retry
        stepContextSupport.startNewExecution(name: 'Step2', retry: true);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, true);
        expect(stepContextSupport.context.stepExecution!.isCompleted, false);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(stepContextSupport.context.stepExecution!.updatedAt, null);
        expect(stepContextSupport.context.stepExecution!.finishedAt, null);
        expect(stepContextSupport.context.taskExecution, null);
        expect(stepContextSupport.branchStatus, BranchStatus.completed);
        stepContextSupport.finishExecutionAsSkipped(retry: true);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, true);
        expect(stepContextSupport.context.stepExecution!.isCompleted, false);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(stepContextSupport.context.stepExecution!.updatedAt, null);
        expect(stepContextSupport.context.stepExecution!.finishedAt, null);
        expect(stepContextSupport.context.taskExecution, null);
        expect(stepContextSupport.branchStatus, BranchStatus.completed);

        {
          //! Task block
          final taskContextSupport =
              _TaskContextSupport(context: stepContextSupport.context);
          expect(taskContextSupport.context.jobExecution != null, true);
          expect(taskContextSupport.context.stepExecution != null, true);
          expect(taskContextSupport.context.taskExecution, null);

          taskContextSupport.startNewExecution(name: 'Task', retry: false);
          //! Job
          expect(taskContextSupport.context.jobExecution!.name, 'Job');
          expect(taskContextSupport.context.jobExecution!.isRunning, true);
          expect(taskContextSupport.context.jobExecution!.isCompleted, false);
          expect(taskContextSupport.context.jobExecution!.isSkipped, false);
          expect(taskContextSupport.context.jobExecution!.updatedAt, null);
          expect(taskContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(taskContextSupport.context.stepExecution!.name, 'Step');
          expect(taskContextSupport.context.stepExecution!.isRunning, true);
          expect(taskContextSupport.context.stepExecution!.isCompleted, false);
          expect(taskContextSupport.context.stepExecution!.isSkipped, false);
          expect(taskContextSupport.context.stepExecution!.updatedAt, null);
          expect(taskContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(taskContextSupport.context.taskExecution!.name, 'Task');
          expect(taskContextSupport.context.taskExecution!.isRunning, true);
          expect(taskContextSupport.context.taskExecution!.isCompleted, false);
          expect(taskContextSupport.context.taskExecution!.isSkipped, false);
          expect(taskContextSupport.context.taskExecution!.updatedAt, null);
          expect(taskContextSupport.context.taskExecution!.finishedAt, null);
          expect(taskContextSupport.branchStatus, BranchStatus.completed);

          // Should skip create new and finish execution on retry
          taskContextSupport.startNewExecution(name: 'Task2', retry: true);
          //! Job
          expect(taskContextSupport.context.jobExecution!.name, 'Job');
          expect(taskContextSupport.context.jobExecution!.isRunning, true);
          expect(taskContextSupport.context.jobExecution!.isCompleted, false);
          expect(taskContextSupport.context.jobExecution!.isSkipped, false);
          expect(taskContextSupport.context.jobExecution!.updatedAt, null);
          expect(taskContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(taskContextSupport.context.stepExecution!.name, 'Step');
          expect(taskContextSupport.context.stepExecution!.isRunning, true);
          expect(taskContextSupport.context.stepExecution!.isCompleted, false);
          expect(taskContextSupport.context.stepExecution!.isSkipped, false);
          expect(taskContextSupport.context.stepExecution!.updatedAt, null);
          expect(taskContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(taskContextSupport.context.taskExecution!.name, 'Task');
          expect(taskContextSupport.context.taskExecution!.isRunning, true);
          expect(taskContextSupport.context.taskExecution!.isCompleted, false);
          expect(taskContextSupport.context.taskExecution!.isSkipped, false);
          expect(taskContextSupport.context.taskExecution!.updatedAt, null);
          expect(taskContextSupport.context.taskExecution!.finishedAt, null);
          expect(taskContextSupport.branchStatus, BranchStatus.completed);
          stepContextSupport.finishExecutionAsSkipped(retry: true);
          //! Job
          expect(taskContextSupport.context.jobExecution!.name, 'Job');
          expect(taskContextSupport.context.jobExecution!.isRunning, true);
          expect(taskContextSupport.context.jobExecution!.isCompleted, false);
          expect(taskContextSupport.context.jobExecution!.isSkipped, false);
          expect(taskContextSupport.context.jobExecution!.updatedAt, null);
          expect(taskContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(taskContextSupport.context.stepExecution!.name, 'Step');
          expect(taskContextSupport.context.stepExecution!.isRunning, true);
          expect(taskContextSupport.context.stepExecution!.isCompleted, false);
          expect(taskContextSupport.context.stepExecution!.isSkipped, false);
          expect(taskContextSupport.context.stepExecution!.updatedAt, null);
          expect(taskContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(taskContextSupport.context.taskExecution!.name, 'Task');
          expect(taskContextSupport.context.taskExecution!.isRunning, true);
          expect(taskContextSupport.context.taskExecution!.isCompleted, false);
          expect(taskContextSupport.context.taskExecution!.isSkipped, false);
          expect(taskContextSupport.context.taskExecution!.updatedAt, null);
          expect(taskContextSupport.context.taskExecution!.finishedAt, null);
          expect(taskContextSupport.branchStatus, BranchStatus.completed);

          taskContextSupport.finishExecutionAsCompleted(retry: false);
          //! Job
          expect(stepContextSupport.context.jobExecution!.name, 'Job');
          expect(stepContextSupport.context.jobExecution!.isRunning, true);
          expect(stepContextSupport.context.jobExecution!.isCompleted, false);
          expect(stepContextSupport.context.jobExecution!.isSkipped, false);
          expect(stepContextSupport.context.jobExecution!.updatedAt, null);
          expect(stepContextSupport.context.jobExecution!.finishedAt, null);
          //! Step
          expect(stepContextSupport.context.stepExecution!.name, 'Step');
          expect(stepContextSupport.context.stepExecution!.isRunning, true);
          expect(stepContextSupport.context.stepExecution!.isCompleted, false);
          expect(stepContextSupport.context.stepExecution!.isSkipped, false);
          expect(stepContextSupport.context.stepExecution!.updatedAt, null);
          expect(stepContextSupport.context.stepExecution!.finishedAt, null);
          //! Task
          expect(stepContextSupport.context.taskExecution!.name, 'Task');
          expect(stepContextSupport.context.taskExecution!.isRunning, false);
          expect(stepContextSupport.context.taskExecution!.isCompleted, true);
          expect(stepContextSupport.context.taskExecution!.isSkipped, false);
          expect(stepContextSupport.context.taskExecution!.updatedAt != null,
              true);
          expect(stepContextSupport.context.taskExecution!.finishedAt != null,
              true);
        }

        stepContextSupport.finishExecutionAsCompleted(retry: false);
        //! Job
        expect(stepContextSupport.context.jobExecution!.name, 'Job');
        expect(stepContextSupport.context.jobExecution!.isRunning, true);
        expect(stepContextSupport.context.jobExecution!.isCompleted, false);
        expect(stepContextSupport.context.jobExecution!.isSkipped, false);
        expect(stepContextSupport.context.jobExecution!.updatedAt, null);
        expect(stepContextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(stepContextSupport.context.stepExecution!.name, 'Step');
        expect(stepContextSupport.context.stepExecution!.isRunning, false);
        expect(stepContextSupport.context.stepExecution!.isCompleted, true);
        expect(stepContextSupport.context.stepExecution!.isSkipped, false);
        expect(
            stepContextSupport.context.stepExecution!.updatedAt != null, true);
        expect(
            stepContextSupport.context.stepExecution!.finishedAt != null, true);
        //! Task
        expect(stepContextSupport.context.taskExecution!.name, 'Task');
        expect(stepContextSupport.context.taskExecution!.isRunning, false);
        expect(stepContextSupport.context.taskExecution!.isCompleted, true);
        expect(stepContextSupport.context.taskExecution!.isSkipped, false);
        expect(
            stepContextSupport.context.taskExecution!.updatedAt != null, true);
        expect(
            stepContextSupport.context.taskExecution!.finishedAt != null, true);
      }

      jobContextSupport.finishExecutionAsCompleted(retry: false);
      //! Job
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, false);
      expect(jobContextSupport.context.jobExecution!.isCompleted, true);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.jobExecution!.finishedAt != null, true);
      //! Step
      expect(jobContextSupport.context.stepExecution!.name, 'Step');
      expect(jobContextSupport.context.stepExecution!.isRunning, false);
      expect(jobContextSupport.context.stepExecution!.isCompleted, true);
      expect(jobContextSupport.context.stepExecution!.isSkipped, false);
      expect(jobContextSupport.context.stepExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.stepExecution!.finishedAt != null, true);
      //! Task
      expect(jobContextSupport.context.taskExecution!.name, 'Task');
      expect(jobContextSupport.context.taskExecution!.isRunning, false);
      expect(jobContextSupport.context.taskExecution!.isCompleted, true);
      expect(jobContextSupport.context.taskExecution!.isSkipped, false);
      expect(jobContextSupport.context.taskExecution!.updatedAt != null, true);
      expect(jobContextSupport.context.taskExecution!.finishedAt != null, true);
    });
  });

  group('Test ContextSupport for complex patterns with branches', () {
    test('Test simple flow "Job → Step → Task" and not a retry', () {
      void startNewJobExecutionAndCheck({
        required _JobContextSupport contextSupport,
        required String jobName,
      }) {
        contextSupport.startNewExecution(name: jobName, retry: false);
        expect(contextSupport.context.jobExecution!.name, jobName);
        expect(contextSupport.context.jobExecution!.isRunning, true);
        expect(contextSupport.context.jobExecution!.isCompleted, false);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt, null);
        expect(contextSupport.context.jobExecution!.finishedAt, null);
        expect(contextSupport.branchStatus, BranchStatus.completed);
      }

      void startNewStepExecutionAndCheck({
        required _StepContextSupport contextSupport,
        required String parentJobName,
        required String stepName,
      }) {
        contextSupport.startNewExecution(name: stepName, retry: false);
        //! Job
        expect(contextSupport.context.jobExecution!.name, parentJobName);
        expect(contextSupport.context.jobExecution!.isRunning, true);
        expect(contextSupport.context.jobExecution!.isCompleted, false);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt, null);
        expect(contextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(contextSupport.context.stepExecution!.name, stepName);
        expect(contextSupport.context.stepExecution!.isRunning, true);
        expect(contextSupport.context.stepExecution!.isCompleted, false);
        expect(contextSupport.context.stepExecution!.isSkipped, false);
        expect(contextSupport.context.stepExecution!.updatedAt, null);
        expect(contextSupport.context.stepExecution!.finishedAt, null);
        expect(contextSupport.branchStatus, BranchStatus.completed);
      }

      void startNewTaskExecutionAndCheck({
        required _TaskContextSupport contextSupport,
        required String parentJobName,
        required String parentStepName,
        required String taskName,
      }) {
        contextSupport.startNewExecution(name: taskName, retry: false);
        //! Job
        expect(contextSupport.context.jobExecution!.name, parentJobName);
        expect(contextSupport.context.jobExecution!.isRunning, true);
        expect(contextSupport.context.jobExecution!.isCompleted, false);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt, null);
        expect(contextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(contextSupport.context.stepExecution!.name, parentStepName);
        expect(contextSupport.context.stepExecution!.isRunning, true);
        expect(contextSupport.context.stepExecution!.isCompleted, false);
        expect(contextSupport.context.stepExecution!.isSkipped, false);
        expect(contextSupport.context.stepExecution!.updatedAt, null);
        expect(contextSupport.context.stepExecution!.finishedAt, null);
        //! Task
        expect(contextSupport.context.taskExecution!.name, taskName);
        expect(contextSupport.context.taskExecution!.isRunning, true);
        expect(contextSupport.context.taskExecution!.isCompleted, false);
        expect(contextSupport.context.taskExecution!.isSkipped, false);
        expect(contextSupport.context.taskExecution!.updatedAt, null);
        expect(contextSupport.context.taskExecution!.finishedAt, null);
        expect(contextSupport.branchStatus, BranchStatus.completed);
      }

      void finishJobExecutionAndCheck({
        required _JobContextSupport contextSupport,
        required String jobName,
        required String childStepName,
        required String childTaskName,
      }) {
        contextSupport.finishExecutionAsCompleted(retry: false);
        //! Job
        expect(contextSupport.context.jobExecution!.name, jobName);
        expect(contextSupport.context.jobExecution!.isRunning, false);
        expect(contextSupport.context.jobExecution!.isCompleted, true);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt != null, true);
        expect(contextSupport.context.jobExecution!.finishedAt != null, true);
        //! Step
        expect(contextSupport.context.stepExecution!.name, childStepName);
        expect(contextSupport.context.stepExecution!.isRunning, false);
        expect(contextSupport.context.stepExecution!.isCompleted, true);
        expect(contextSupport.context.stepExecution!.isSkipped, false);
        expect(contextSupport.context.stepExecution!.updatedAt != null, true);
        expect(contextSupport.context.stepExecution!.finishedAt != null, true);
        //! Task
        expect(contextSupport.context.taskExecution!.name, childTaskName);
        expect(contextSupport.context.taskExecution!.isRunning, false);
        expect(contextSupport.context.taskExecution!.isCompleted, true);
        expect(contextSupport.context.taskExecution!.isSkipped, false);
        expect(contextSupport.context.taskExecution!.updatedAt != null, true);
        expect(contextSupport.context.taskExecution!.finishedAt != null, true);
      }

      void finishStepExecutionAndCheck({
        required _StepContextSupport contextSupport,
        required String parentJobName,
        required String stepName,
        required String childTaskName,
      }) {
        contextSupport.finishExecutionAsCompleted(retry: false);
        //! Job
        expect(contextSupport.context.jobExecution!.name, parentJobName);
        expect(contextSupport.context.jobExecution!.isRunning, true);
        expect(contextSupport.context.jobExecution!.isCompleted, false);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt, null);
        expect(contextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(contextSupport.context.stepExecution!.name, stepName);
        expect(contextSupport.context.stepExecution!.isRunning, false);
        expect(contextSupport.context.stepExecution!.isCompleted, true);
        expect(contextSupport.context.stepExecution!.isSkipped, false);
        expect(contextSupport.context.stepExecution!.updatedAt != null, true);
        expect(contextSupport.context.stepExecution!.finishedAt != null, true);
        //! Task
        expect(contextSupport.context.taskExecution!.name, childTaskName);
        expect(contextSupport.context.taskExecution!.isRunning, false);
        expect(contextSupport.context.taskExecution!.isCompleted, true);
        expect(contextSupport.context.taskExecution!.isSkipped, false);
        expect(contextSupport.context.taskExecution!.updatedAt != null, true);
        expect(contextSupport.context.taskExecution!.finishedAt != null, true);
      }

      void finishTaskExecutionAndCheck({
        required _TaskContextSupport contextSupport,
        required String parentJobName,
        required String parentStepName,
        required String taskName,
      }) {
        contextSupport.finishExecutionAsCompleted(retry: false);
        //! Job
        expect(contextSupport.context.jobExecution!.name, parentJobName);
        expect(contextSupport.context.jobExecution!.isRunning, true);
        expect(contextSupport.context.jobExecution!.isCompleted, false);
        expect(contextSupport.context.jobExecution!.isSkipped, false);
        expect(contextSupport.context.jobExecution!.updatedAt, null);
        expect(contextSupport.context.jobExecution!.finishedAt, null);
        //! Step
        expect(contextSupport.context.stepExecution!.name, parentStepName);
        expect(contextSupport.context.stepExecution!.isRunning, true);
        expect(contextSupport.context.stepExecution!.isCompleted, false);
        expect(contextSupport.context.stepExecution!.isSkipped, false);
        expect(contextSupport.context.stepExecution!.updatedAt, null);
        expect(contextSupport.context.stepExecution!.finishedAt, null);
        //! Task
        expect(contextSupport.context.taskExecution!.name, taskName);
        expect(contextSupport.context.taskExecution!.isRunning, false);
        expect(contextSupport.context.taskExecution!.isCompleted, true);
        expect(contextSupport.context.taskExecution!.isSkipped, false);
        expect(contextSupport.context.taskExecution!.updatedAt != null, true);
        expect(contextSupport.context.taskExecution!.finishedAt != null, true);
      }

      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.context.taskExecution, null);

      startNewJobExecutionAndCheck(
        contextSupport: jobContextSupport,
        jobName: 'Job',
      );

      {
        //! Step block
        final stepContextSupport =
            _StepContextSupport(context: jobContextSupport.context);

        startNewStepExecutionAndCheck(
          contextSupport: stepContextSupport,
          parentJobName: 'Job',
          stepName: 'Step',
        );

        {
          //! Task block
          final taskContextSupport =
              _TaskContextSupport(context: stepContextSupport.context);

          startNewTaskExecutionAndCheck(
            contextSupport: taskContextSupport,
            parentJobName: 'Job',
            parentStepName: 'Step',
            taskName: 'Task',
          );

          startNewTaskExecutionAndCheck(
            contextSupport: taskContextSupport,
            parentJobName: 'Job',
            parentStepName: 'Step',
            taskName: 'Task2',
          );

          finishTaskExecutionAndCheck(
            contextSupport: taskContextSupport,
            parentJobName: 'Job',
            parentStepName: 'Step',
            taskName: 'Task2',
          );

          finishTaskExecutionAndCheck(
            contextSupport: taskContextSupport,
            parentJobName: 'Job',
            parentStepName: 'Step',
            taskName: 'Task',
          );
        }

        {
          //! Branched Step block
          startNewStepExecutionAndCheck(
            contextSupport: stepContextSupport,
            parentJobName: 'Job',
            stepName: 'Step2',
          );

          {
            //! Task block
            final taskContextSupport =
                _TaskContextSupport(context: stepContextSupport.context);

            startNewTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job',
              parentStepName: 'Step2',
              taskName: 'Task3',
            );

            startNewTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job',
              parentStepName: 'Step2',
              taskName: 'Task4',
            );

            finishTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job',
              parentStepName: 'Step2',
              taskName: 'Task4',
            );

            finishTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job',
              parentStepName: 'Step2',
              taskName: 'Task3',
            );
          }

          finishStepExecutionAndCheck(
            contextSupport: stepContextSupport,
            parentJobName: 'Job',
            stepName: 'Step2',
            childTaskName: 'Task3',
          );
        }

        finishStepExecutionAndCheck(
          contextSupport: stepContextSupport,
          parentJobName: 'Job',
          stepName: 'Step',
          childTaskName: 'Task3',
        );
      }

      {
        //! Branched Job block
        startNewJobExecutionAndCheck(
          contextSupport: jobContextSupport,
          jobName: 'Job2',
        );

        {
          //! Step block
          final stepContextSupport =
              _StepContextSupport(context: jobContextSupport.context);

          startNewStepExecutionAndCheck(
            contextSupport: stepContextSupport,
            parentJobName: 'Job2',
            stepName: 'Step10',
          );

          {
            //! Task block
            final taskContextSupport =
                _TaskContextSupport(context: stepContextSupport.context);

            startNewTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job2',
              parentStepName: 'Step10',
              taskName: 'Task20',
            );

            startNewTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job2',
              parentStepName: 'Step10',
              taskName: 'Task21',
            );

            finishTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job2',
              parentStepName: 'Step10',
              taskName: 'Task21',
            );

            finishTaskExecutionAndCheck(
              contextSupport: taskContextSupport,
              parentJobName: 'Job2',
              parentStepName: 'Step10',
              taskName: 'Task20',
            );
          }

          {
            //! Branched Step block
            startNewStepExecutionAndCheck(
              contextSupport: stepContextSupport,
              parentJobName: 'Job2',
              stepName: 'Step11',
            );

            {
              //! Task block
              final taskContextSupport =
                  _TaskContextSupport(context: stepContextSupport.context);

              startNewTaskExecutionAndCheck(
                contextSupport: taskContextSupport,
                parentJobName: 'Job2',
                parentStepName: 'Step11',
                taskName: 'Task30',
              );

              startNewTaskExecutionAndCheck(
                contextSupport: taskContextSupport,
                parentJobName: 'Job2',
                parentStepName: 'Step11',
                taskName: 'Task31',
              );

              finishTaskExecutionAndCheck(
                contextSupport: taskContextSupport,
                parentJobName: 'Job2',
                parentStepName: 'Step11',
                taskName: 'Task31',
              );

              finishTaskExecutionAndCheck(
                contextSupport: taskContextSupport,
                parentJobName: 'Job2',
                parentStepName: 'Step11',
                taskName: 'Task30',
              );
            }

            finishStepExecutionAndCheck(
              contextSupport: stepContextSupport,
              parentJobName: 'Job2',
              stepName: 'Step11',
              childTaskName: 'Task30',
            );
          }

          finishStepExecutionAndCheck(
            contextSupport: stepContextSupport,
            parentJobName: 'Job2',
            stepName: 'Step10',
            childTaskName: 'Task30',
          );
        }

        finishJobExecutionAndCheck(
          contextSupport: jobContextSupport,
          jobName: 'Job2',
          childStepName: 'Step10',
          childTaskName: 'Task30',
        );
      }

      finishJobExecutionAndCheck(
        contextSupport: jobContextSupport,
        jobName: 'Job',
        childStepName: 'Step10',
        childTaskName: 'Task30',
      );
    });
  });
}

class _JobContextSupport extends ContextSupport<Job> {
  _JobContextSupport() : super(context: ExecutionContext());
}

class _StepContextSupport extends ContextSupport<Step> {
  _StepContextSupport({required ExecutionContext context})
      : super(context: context);
}

class _TaskContextSupport extends ContextSupport<Task> {
  _TaskContextSupport({required ExecutionContext context})
      : super(context: context);
}
