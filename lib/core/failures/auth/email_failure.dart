import 'package:mobile/core/failures/failure.dart';

class EmailFailure extends Failure {
  const EmailFailure(super.message);

  factory EmailFailure.empty() {
    return const EmailFailure('This field is required.');
  }

  factory EmailFailure.invalid() {
    return const EmailFailure('Invalid email');
  }
}
