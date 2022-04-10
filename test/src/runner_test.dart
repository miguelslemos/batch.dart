// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/runner.dart';

class TestRunner implements Runner {
  bool result = false;
  @override
  Future<void> run() async => result = true;
}

void main() {
  test('Test Runner', () {
    final runner = TestRunner();
    runner.run();
    expect(runner.result, true);
  });
}
