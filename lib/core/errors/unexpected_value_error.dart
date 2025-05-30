

import 'package:mobile/core/failures/failure.dart';

class UnexpectedValueError extends Error {
  final Failure valueFailure;

  UnexpectedValueError(this.valueFailure);

  @override
  String toString() {
    const explanation =
        'Encountered a ValueFailure at an unrecoverable point. Terminating.';

    return Error.safeToString('$explanation Failure was: $valueFailure');
  }
}
