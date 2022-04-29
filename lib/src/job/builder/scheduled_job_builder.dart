// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/event/scheduled_job.dart';

abstract class ScheduledJobBuilder {
  /// Returns the scheduled job object.
  ScheduledJob build();
}
