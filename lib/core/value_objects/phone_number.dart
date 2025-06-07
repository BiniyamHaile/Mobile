import 'package:dartz/dartz.dart';
import 'package:mobile/core/failures/auth/phone_number_failure.dart';
import 'package:mobile/core/value_objects/value_object.dart';

class PhoneNumber extends ValueObject<String> {
  @override
  final Either<PhoneNumberFailure, String> value;

  factory PhoneNumber(String input) {
    return PhoneNumber._(
      validatePhoneNumber(input),
    );
  }

  const PhoneNumber._(this.value);
}

Either<PhoneNumberFailure, String> validatePhoneNumber(String input) {
  const phoneRegex = r'^\+?[1-9]\d{1,14}$';
  if (input.isEmpty) {
    return left(PhoneNumberFailure.empty());
  } else if (!RegExp(phoneRegex).hasMatch(input)) {
    return left(PhoneNumberFailure.invalid());
  } else {
    return right(input);
  }
}
