// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

import '../../utils.dart';

enum BranchStatus {
  /// This element indicates that a particular task process has finished successfully.
  succeeded,

  /// This element indicates that a particular task process has failed.
  failed,

  /// This element indicates that a particular task process will always be executed
  /// regardless of whether it succeeds or fails.
  completed,
}

extension BranchStatusExtension on BranchStatus {
  String get name => getEnumName(this);
}
