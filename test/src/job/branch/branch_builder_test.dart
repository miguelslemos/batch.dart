// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/branch/branch_builder.dart';
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/event/job.dart';

void main() {
  test('Test BranchBuilder', () {
    final to = Job(name: 'Job', steps: []);
    final builder = BranchBuilder<Job>();
    builder.on(BranchStatus.succeeded);
    builder.to(to);

    final branch = builder.build();
    expect(branch.on, BranchStatus.succeeded);
    expect(branch.to, to);
  });

  test('Test when builder has no on parameter', () {
    final to = Job(name: 'Job', steps: []);
    final builder = BranchBuilder<Job>();
    builder.to(to);

    expect(
      () => builder.build(),
      throwsA(
        allOf(
          isA<ArgumentError>(),
          predicate((dynamic e) =>
              e.message == 'Set the branch status for this branch.'),
        ),
      ),
    );
  });

  test('Test when builder has no to parameter', () {
    final builder = BranchBuilder<Job>();
    builder.on(BranchStatus.succeeded);

    expect(
      () => builder.build(),
      throwsA(
        allOf(
          isA<ArgumentError>(),
          predicate((dynamic e) =>
              e.message == 'Set the next point for this branch.'),
        ),
      ),
    );
  });
}
