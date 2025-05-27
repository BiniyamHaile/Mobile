part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoading extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  ForgotPasswordSuccess({required this.message});
}

final class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  ForgotPasswordFailure({required this.error});
}
