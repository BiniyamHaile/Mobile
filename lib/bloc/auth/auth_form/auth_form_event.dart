part of 'auth_form_bloc.dart';

sealed class AuthFormEvent {}

class EmailChanged extends AuthFormEvent {
  final String email;

  EmailChanged(this.email);
}

class PasswordChanged extends AuthFormEvent {
  final String password;

  PasswordChanged(this.password);
}

class NameChanged extends AuthFormEvent {
  final String name;

  NameChanged(this.name);
}

class SurnameChanged extends AuthFormEvent {
  final String surname;

  SurnameChanged(this.surname);
}

class ConfirmPasswordChanged extends AuthFormEvent {
  final String confirmPassword;
  final String password;

  ConfirmPasswordChanged({
    required this.confirmPassword,
    required this.password,
  });
}
