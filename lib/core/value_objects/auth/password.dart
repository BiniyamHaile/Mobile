import 'package:dartz/dartz.dart';
import 'package:mobile/core/failures/auth/password_failure.dart';
import 'package:mobile/core/value_objects/value_object.dart';

class Password extends ValueObject<String> {
  static int get minPasswordLength => 8;
  static int get maxErrorStrength => 5;

  @override
  final Either<PasswordFailure, String> value;

  factory Password(String input) {
    return Password._(
      validatePassword(input),
    );
  }

  const Password._(this.value);
}

Either<PasswordFailure, String> validatePassword(String input) {
  if (input.trim().isEmpty) {
    return left(PasswordFailure.empty());
  }
  if (input.length < 8) {
    return left(PasswordFailure.tooShort());
  }
  if (!RegExp(r'[A-Z]').hasMatch(input)) {
    return left(PasswordFailure.noUppercase());
  }
  if (!RegExp(r'[0-9]').hasMatch(input)) {
    return left(PasswordFailure.noNumber());
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(input)) {
    return left(PasswordFailure.noSpecialChar());
  }
  return right(input);
}
