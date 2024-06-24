// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/context/context_support.dart';
import 'package:batch/src/job/context/execution_context.dart';
import 'package:batch/src/job/event/base_step.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/log/log_configuration.dart';
import 'package:batch/src/log/logger.dart';

void main() {
  //! Required to load logger to run ContextSupport.
  Logger.loadFromConfig(LogConfiguration(printLog: false));

  group('Test ContextSupport for Job', () {
    test('Test when not a retry and complete', () {
      final contextSupport = _JobContextSupport();
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);

      contextSupport.startNewExecution(name: 'Job', retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, true);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt, null);
      expect(contextSupport.context.jobExecution!.finishedAt, null);
      expect(contextSupport.context.stepExecution, null);
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
    });

    test('Test when a retry and skip', () {
      final contextSupport = _JobContextSupport();
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);

      contextSupport.startNewExecution(name: 'Job', retry: false);
      expect(contextSupport.context.jobExecution!.name, 'Job');
      expect(contextSupport.context.jobExecution!.isRunning, true);
      expect(contextSupport.context.jobExecution!.isCompleted, false);
      expect(contextSupport.context.jobExecution!.isSkipped, false);
      expect(contextSupport.context.jobExecution!.updatedAt, null);
      expect(contextSupport.context.jobExecution!.finishedAt, null);
      expect(contextSupport.context.stepExecution, null);
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
    });
  });

  group('Test ContextSupport for Step', () {
    test('Test when not a retry and complete', () {
      final contextSupport = _StepContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);

      contextSupport.startNewExecution(name: 'Step', retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, true);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt, null);
      expect(contextSupport.context.stepExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
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
    });

    test('Test when a retry and skip', () {
      final contextSupport = _StepContextSupport(context: ExecutionContext());
      expect(contextSupport.context.jobExecution, null);
      expect(contextSupport.context.stepExecution, null);

      contextSupport.startNewExecution(name: 'Step', retry: false);
      expect(contextSupport.context.stepExecution!.name, 'Step');
      expect(contextSupport.context.stepExecution!.isRunning, true);
      expect(contextSupport.context.stepExecution!.isCompleted, false);
      expect(contextSupport.context.stepExecution!.isSkipped, false);
      expect(contextSupport.context.stepExecution!.updatedAt, null);
      expect(contextSupport.context.stepExecution!.finishedAt, null);
      expect(contextSupport.context.jobExecution, null);
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
    });
  });

  group('Test ContextSupport for complex patterns', () {
    test('Test simple flow "Job → Step → Task" and not a retry', () {
      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);

      jobContextSupport.startNewExecution(name: 'Job', retry: false);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);

      {
        //! Step block
        final stepContextSupport =
            _StepContextSupport(context: jobContextSupport.context);
        expect(stepContextSupport.context.jobExecution != null, true);
        expect(stepContextSupport.context.stepExecution, null);

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
        expect(stepContextSupport.branchStatus, BranchStatus.completed);

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
    });

    test('Test simple flow "Job → Step → Task" and a retry', () {
      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);

      jobContextSupport.startNewExecution(name: 'Job', retry: false);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
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
      expect(jobContextSupport.branchStatus, BranchStatus.completed);
      jobContextSupport.finishExecutionAsSkipped(retry: true);
      expect(jobContextSupport.context.jobExecution!.name, 'Job');
      expect(jobContextSupport.context.jobExecution!.isRunning, true);
      expect(jobContextSupport.context.jobExecution!.isCompleted, false);
      expect(jobContextSupport.context.jobExecution!.isSkipped, false);
      expect(jobContextSupport.context.jobExecution!.updatedAt, null);
      expect(jobContextSupport.context.jobExecution!.finishedAt, null);
      expect(jobContextSupport.context.stepExecution, null);
      expect(jobContextSupport.branchStatus, BranchStatus.completed);

      {
        //! Step block
        final stepContextSupport =
            _StepContextSupport(context: jobContextSupport.context);
        expect(stepContextSupport.context.jobExecution != null, true);
        expect(stepContextSupport.context.stepExecution, null);

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
        expect(stepContextSupport.branchStatus, BranchStatus.completed);

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
      }

      final jobContextSupport = _JobContextSupport();
      expect(jobContextSupport.context.jobExecution, null);
      expect(jobContextSupport.context.stepExecution, null);

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
          //! Branched Step block
          startNewStepExecutionAndCheck(
            contextSupport: stepContextSupport,
            parentJobName: 'Job',
            stepName: 'Step2',
          );

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
            //! Branched Step block
            startNewStepExecutionAndCheck(
              contextSupport: stepContextSupport,
              parentJobName: 'Job2',
              stepName: 'Step11',
            );

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

class _StepContextSupport extends ContextSupport<BaseStep> {
  _StepContextSupport({required ExecutionContext context})
      : super(context: context);
}
