import 'package:flutter/foundation.dart';

bool _defaultValidator(dynamic value) => true;

/// Wrapper for a single value with optional validation.
class GValue<T> extends ValueNotifier<T> {
  /// Validation function for the value.
  final bool Function(T) validator;

  /// Sets a new value with validation.
  @override
  set value(T newValue) {
    assert(validator(newValue), 'Invalid value');
    super.value = newValue;
    if (super.hasListeners) {
      notifyListeners();
    }
  }

  /// Creates a value with optional validation.
  GValue(T initialValue, {this.validator = _defaultValidator})
    : super(initialValue) {
    assert(validator(initialValue), 'Invalid value');
  }
}
