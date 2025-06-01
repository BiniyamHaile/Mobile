part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordEvent {}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordSubmitted({required this.email});
}
