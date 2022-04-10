// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Project imports:
import 'package:batch/src/job/parameter/parameter.dart';

class Parameters {
  /// The objects
  final _objects = <Parameter>[];

  /// Returns the parameter value associated with [key].
  dynamic operator [](final String key) {
    if (!contains(key)) {
      throw ArgumentError('There is no parameter associated with [key=$key].');
    }

    for (final parameter in _objects) {
      if (parameter.key == key) {
        return parameter.value;
      }
    }
  }

  /// Adds [value] as a parameter associated with [key].
  void operator []=(final String key, final dynamic value) => _objects
    ..removeWhere((parameter) => parameter.key == key)
    ..add(Parameter(key: key, value: value));

  /// Removes all parameters.
  void removeAll() => _objects.removeRange(0, _objects.length);

  /// Returns true if this object has [key] passed as an argument, otherwise false.
  bool contains(final String key) {
    for (final parameter in _objects) {
      if (parameter.key == key) {
        return true;
      }
    }

    return false;
  }

  // Returns true if this object has no parameter, otherwise false.
  bool get isEmpty => _objects.isEmpty;

  /// Returns true if this object has parameter, otherwise false.
  bool get isNotEmpty => _objects.isNotEmpty;

  /// Returns the number of parameters.
  int get length => _objects.length;

  @override
  String toString() => _objects.toString();
}
