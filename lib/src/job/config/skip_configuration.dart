// Copyright (c) 2022, Kato Shinya. All rights reserved.
// Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

abstract class SkipConfiguration {
  /// Returns the new instance of [SkipConfiguration].
  factory SkipConfiguration({required List<Exception> skippableExceptions}) =>
      _SkipConfiguration(
          //! The "is" modifier, which allows reference up to the parent of the target object,
          //! is preferred for type determination, but the right side of the "is" modifier cannot be
          //! a variable due to the Dart language specification. Therefore, type determination is currently
          //! performed by comparing strings.
          skippableExceptions: skippableExceptions
              .map((exception) => exception.runtimeType.toString())
              .toList());

  /// Returns the skippable exceptions.
  List<String> get skippableExceptions;
}

/// The implementation class of [SkipConfiguration].
class _SkipConfiguration implements SkipConfiguration {
  /// Returns the new instance of [_SkipConfiguration].
  _SkipConfiguration({required this.skippableExceptions});

  @override
  final List<String> skippableExceptions;
}
