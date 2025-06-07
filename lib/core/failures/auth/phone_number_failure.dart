import 'package:mobile/core/failures/failure.dart';

class PhoneNumberFailure extends Failure {
  const PhoneNumberFailure(super.message);

  factory PhoneNumberFailure.empty() {
    return const PhoneNumberFailure('This field is required.');
  }
  factory PhoneNumberFailure.invalid() {
    return const PhoneNumberFailure('Invalid Email.');
  }
}
