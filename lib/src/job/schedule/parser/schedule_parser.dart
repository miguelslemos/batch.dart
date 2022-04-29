// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:;

// Project imports:
import 'package:batch/src/job/schedule/model/schedule.dart';

abstract class ScheduleParser<R extends Schedule> {
  /// Returns the parsed schedule.
  R parse();
}
