part of 'otp_bloc.dart';

@immutable
abstract class OtpEvent {}

class OtpSubmitted extends OtpEvent {
  final String email;
  final String code;
  OtpSubmitted({required this.email, required this.code});
}

class OtpResendRequested extends OtpEvent {
  final String email;

  OtpResendRequested({required this.email});
}
