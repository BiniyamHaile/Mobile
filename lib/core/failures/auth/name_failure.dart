import 'package:mobile/core/failures/failure.dart';

class NameFailure extends Failure {
  const NameFailure(super.message);

  factory NameFailure.empty() {
    return const NameFailure('This field is required.');
  }

  factory NameFailure.tooShort() {
    return const NameFailure('Name is too short.');
  }
}
