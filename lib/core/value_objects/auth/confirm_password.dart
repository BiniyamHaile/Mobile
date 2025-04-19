

import 'package:dartz/dartz.dart';
import 'package:mobile/core/failures/auth/confirm_password_failure.dart';
import 'package:mobile/core/value_objects/value_object.dart';

class ConfirmPassword extends ValueObject<String> {
  @override
  final Either<ConfirmPasswordFailure, String> value;

  factory ConfirmPassword({
    required String input,
    required String password,
  }) {
    return ConfirmPassword._(
      validateConfirmPassword(input, password),
    );
  }

  const ConfirmPassword._(this.value);
}


Either<ConfirmPasswordFailure, String> validateConfirmPassword(
    String input, String password) {
  if (input.trim().isEmpty) {
    return left(ConfirmPasswordFailure.empty());
  }
  if (input != password) {
    return left(ConfirmPasswordFailure.misMatch());
  }
  return right(input);
}
