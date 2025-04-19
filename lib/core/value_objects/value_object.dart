
import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/unexpected_value_error.dart';
import 'package:mobile/core/failures/failure.dart';

abstract class ValueObject<T> {
  const ValueObject();
  Either<Failure, T> get value;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ValueObject<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';

  bool isValid() => value.isRight();

  T getOrCrash() {
    return value.fold((f) => throw UnexpectedValueError(f), id);
  }
}
