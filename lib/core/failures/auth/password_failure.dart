import 'package:mobile/core/failures/failure.dart';

class PasswordFailure extends Failure {
  const PasswordFailure(super.message);

  factory PasswordFailure.empty() {
    return PasswordFailure('This field is required.');
  }

  factory PasswordFailure.tooShort() {
    return PasswordFailure('Password is too short.');
  }

  factory PasswordFailure.noUppercase() {
    return PasswordFailure( 'Password must contain at least one uppercase letter.');
  }

  factory PasswordFailure.noNumber() {
    return PasswordFailure('Password must contain at least one number.');
  }

  factory PasswordFailure.noSpecialChar() {
    return PasswordFailure( 'Password must contain at least one special character (@\$!%*?&).');
  }
}
