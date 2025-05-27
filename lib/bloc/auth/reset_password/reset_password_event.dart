part of 'reset_password_bloc.dart';

@immutable
sealed class ResetPasswordEvent {}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String email;
  final String resetCode;
  final String newPassword;

  ResetPasswordSubmitted({
    required this.email,
    required this.resetCode,
    required this.newPassword,
  });
}
