
import 'package:mobile/core/failures/failure.dart';

class ConfirmPasswordFailure extends Failure {
  const ConfirmPasswordFailure(super.message);

  factory ConfirmPasswordFailure.empty() {
    return const ConfirmPasswordFailure( 'This field is required.');
  }

  factory ConfirmPasswordFailure.misMatch() {
    return const ConfirmPasswordFailure('Passwords do not match.');
  }
}
