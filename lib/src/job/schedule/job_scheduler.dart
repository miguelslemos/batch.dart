// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:async';

// Project imports:
import 'package:batch/src/batch_instance.dart';
import 'package:batch/src/batch_status.dart';
import 'package:batch/src/job/event/job.dart';
import 'package:batch/src/job/launcher/job_launcher.dart';
import 'package:batch/src/log/logger.dart';
import 'package:batch/src/log/logger_provider.dart';

class JobScheduler {
  /// Returns the new instance of [Job].
  JobScheduler(List<Job> job) : _jobs = job;

  /// The jobs
  final List<Job> _jobs;

  Future<void> run() async {
    log.info('Detected ${_jobs.length} Jobs on the root');
    for (final job in _jobs) {
      log.info('Scheduling Job [name=${job.name}]');
      try {
        BatchInstance.updateStatus(BatchStatus.running);
        log.info(
          'Batch application is now running',
        );
        await JobLauncher(job: job).run();
        log.warn('Preparing for shutdown the batch application safely');
      } catch (_) {
        log.fatal('Shut down the application due to a fatal exception');
        rethrow;
      } finally {
        _dispose();
      }
    }
  }

  void _dispose() {
    BatchInstance.updateStatus(BatchStatus.shuttingDown);
    log.warn('Allocation memory is releasing');
    log.warn('Shutdown the batch application');
    Logger.instance.dispose();
    BatchInstance.updateStatus(BatchStatus.shutdown);
  }
}
