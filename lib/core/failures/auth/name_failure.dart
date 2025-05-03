import 'package:mobile/core/failures/failure.dart';

class NameFailure extends Failure {
  const NameFailure(super.message);

  factory NameFailure.empty() {
    return NameFailure('This field is required.');
  }

  factory NameFailure.tooShort() {
    return NameFailure('Name is too short.');
  }
}
