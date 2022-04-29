// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/branch/branch.dart';
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/event/job.dart';

void main() {
  test('Test Branch', () {
    final to = Job(name: 'Job', steps: []);
    final branch = Branch<Job>(
      on: BranchStatus.completed,
      to: to,
    );

    expect(branch.on, BranchStatus.completed);
    expect(branch.to, to);
  });
}
