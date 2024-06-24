// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

class Parameters {
  /// The objects
  final _objects = <String, dynamic>{};

  /// Returns the parameter value associated with [key].
  dynamic operator [](final String key) => _objects[key];

  /// Adds [value] as a parameter associated with [key].
  void operator []=(final String key, final dynamic value) =>
      _objects[key] = value;

  /// Removes all parameters.
  void removeAll() => _objects.clear();

  /// Returns true if this object has [key] passed as an argument, otherwise false.
  bool contains(final String key) => _objects.containsKey(key);

  /// Applies [action] to each key/value pair of the map.
  /// Calling action must not add or remove keys from the map.
  void forEach(void Function(String key, dynamic value) action) =>
      _objects.forEach((key, value) => action(key, value));

  /// Adds all key/value pairs of [other] to this object.
  void addAll(Map<String, dynamic> other) => _objects.addAll(other);

  // Returns true if this object has no parameter, otherwise false.
  bool get isEmpty => _objects.isEmpty;

  /// Returns true if this object has parameter, otherwise false.
  bool get isNotEmpty => _objects.isNotEmpty;

  /// Returns the number of parameters.
  int get length => _objects.length;

  @override
  String toString() => _objects.toString();
}
