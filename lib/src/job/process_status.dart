// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

import '../utils.dart';

/// The enum represents status of batch processing.
enum ProcessStatus {
  /// This element indicates that the processing is already started and running.
  running,

  /// This element indicates that the processing is skipped for some reason.
  skipped,

  /// This element indicates that the processing is completed.
  completed,
}

extension ProcessStatusExtension on ProcessStatus {
  String get name => getEnumName(this);
}
