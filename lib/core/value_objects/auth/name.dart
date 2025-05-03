import 'package:dartz/dartz.dart';
import 'package:mobile/core/failures/auth/name_failure.dart';
import 'package:mobile/core/value_objects/value_object.dart';

class Name extends ValueObject<String> {
  @override
  final Either<NameFailure, String> value;

  factory Name(String input) {
    return Name._(
      validateName(input),
    );
  }

  const Name._(this.value);
}

Either<NameFailure, String> validateName(String input) {
  if (input.trim().isEmpty) {
    return left(NameFailure.empty());
  } else if (input.length < 3) {
    return left(NameFailure.tooShort());
  }
  return right(input);
}
