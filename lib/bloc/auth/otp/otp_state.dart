part of 'otp_bloc.dart';

@immutable
sealed class OtpState {}

final class OtpInitial extends OtpState {}

final class OtpLoading extends OtpState {}

final class OtpSuccess extends OtpState {
  final String message;
  OtpSuccess({required this.message});
}

final class OtpFailure extends OtpState {
  final String error;
  OtpFailure({required this.error});
}
