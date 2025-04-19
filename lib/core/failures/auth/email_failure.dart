import 'package:mobile/core/failures/failure.dart';

class EmailFailure extends Failure {
  const EmailFailure(super.message);

  factory EmailFailure.empty() {
    return EmailFailure('This field is required.');
  }

  factory EmailFailure.invalid() {
    return EmailFailure('Invalid email');
  }
}
