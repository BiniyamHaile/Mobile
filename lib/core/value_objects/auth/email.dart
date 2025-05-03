

import 'package:dartz/dartz.dart';
import 'package:mobile/core/failures/auth/email_failure.dart';
import 'package:mobile/core/value_objects/value_object.dart';

class Email extends ValueObject<String> {
  @override
  final Either<EmailFailure, String> value;

  factory Email(String? input) {
    return Email._(
      validateEmail(input),
    );
  }

  const Email._(this.value);

  String? fold() {
    return value.fold((failure) => null, (emailString) => emailString);
  }
}

Either<EmailFailure, String> validateEmail(String? input) {
  if (input == null) {
    return left(EmailFailure.empty());
  }

  if (input.trim().isEmpty) {
    return left(EmailFailure.empty());
  }
  final emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
  if (!RegExp(emailPattern).hasMatch(input)) {
    return left(EmailFailure.invalid());
  }
  return right(input);
}
