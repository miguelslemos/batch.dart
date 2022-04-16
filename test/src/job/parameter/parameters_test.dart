// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:batch/src/job/parameter/parameters.dart';

void main() {
  test('Test Parameters', () {
    final parameters = Parameters();
    expect(parameters.isEmpty, true);
    expect(parameters.isNotEmpty, false);

    parameters['testKey'] = 0;
    expect(parameters.isEmpty, false);
    expect(parameters.isNotEmpty, true);
    expect(parameters.contains('testKey'), true);
    expect(parameters.contains('test'), false);
    expect(parameters['testKey'], 0);
    expect(parameters.toString(), '{testKey: 0}');

    parameters.removeAll();
    expect(parameters.isEmpty, true);
    expect(parameters.isNotEmpty, false);
    expect(parameters.contains('testKey'), false);
  });

  test('Test duplicated keys', () {
    final parameters = Parameters();
    parameters['duplicatedKey'] = false;
    parameters['duplicatedKey'] = true;

    expect(parameters['duplicatedKey'], isTrue);
    expect(parameters.length == 1, isTrue);

    parameters['duplicatedKey'] = false;

    expect(parameters['duplicatedKey'], isFalse);
    expect(parameters.length == 1, isTrue);
  });
}
