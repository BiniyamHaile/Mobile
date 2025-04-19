
import 'package:mobile/core/failures/failure.dart';

class ConfirmPasswordFailure extends Failure {
  const ConfirmPasswordFailure(super.message);

  factory ConfirmPasswordFailure.empty() {
    return ConfirmPasswordFailure( 'This field is required.');
  }

  factory ConfirmPasswordFailure.misMatch() {
    return ConfirmPasswordFailure('Passwords do not match.');
  }
}
