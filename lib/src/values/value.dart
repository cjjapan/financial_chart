import 'package:flutter/foundation.dart';

bool _defaultValidator(dynamic value) => true;

/// A wrapper of a single value with type <[T]> and an optional validator.
class GValue<T> extends ValueNotifier<T> {
  final bool Function(T) validator;

  /// Set new value with validation.
  @override
  set value(T newValue) {
    assert(validator(newValue), 'Invalid value');
    super.value = newValue;
  }

  GValue(T initialValue, {this.validator = _defaultValidator})
    : super(initialValue) {
    assert(validator(initialValue), 'Invalid value');
  }

  /// get current value if [newValue] is not provided.
  /// set [newValue] as the new value if it is not null and return the updated value.
  T call({T? newValue}) {
    if (newValue != null) {
      value = newValue;
    }
    return value;
  }
}
