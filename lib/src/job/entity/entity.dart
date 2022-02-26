// Copyright (c) 2022, Kato Shinya. All rights reserved.
// Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Project imports:
import 'package:batch/src/job/branch/branch.dart';
import 'package:batch/src/job/branch/branch_status.dart';
import 'package:batch/src/job/builder/branch_builder.dart';
import 'package:batch/src/job/precondition.dart';

/// This is an abstract class that represents an entity in Job execution.
abstract class Entity<T extends Entity<T>> {
  /// Returns the new instance of [Entity].
  Entity({
    required this.name,
    Precondition? precondition,
  }) : _precondition = precondition;

  /// The name
  final String name;

  /// The precondition
  final Precondition? _precondition;

  /// The branches
  final List<Branch<T>> branches = [];

  /// Returns true if this entity can launch, otherwise false.
  bool canLaunch() {
    if (_precondition == null) {
      return true;
    }

    return _precondition!.check();
  }

  /// Add a branch in case the parent process is succeeded.
  void branchOnSucceeded({required T to}) =>
      _addNewBranch(on: BranchStatus.succeeded, to: to);

  /// Adds a branch in case the parent process is failed.
  void branchOnFailed({required T to}) =>
      _addNewBranch(on: BranchStatus.failed, to: to);

  /// Adds a branch in case the parent process is completed regardless success
  /// and failure of the process.
  void branchOnCompleted({required T to}) =>
      _addNewBranch(on: BranchStatus.completed, to: to);

  /// Returns true if this step has branch, otherwise false.
  bool get hasBranch => branches.isNotEmpty;

  /// Adds new [Branch] based on [on] and [to].
  void _addNewBranch({required BranchStatus on, required T to}) =>
      branches.add(BranchBuilder<T>().on(on).to(to).build());
}
