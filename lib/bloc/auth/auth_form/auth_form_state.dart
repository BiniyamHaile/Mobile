part of 'auth_form_bloc.dart';

class AuthFormState extends Equatable {
  final Name name;
  final Name surname;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;

  const AuthFormState({
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  AuthFormState copyWith({
    Name? name,
    Name? surname,
    Email? email,
    Password? password,
    ConfirmPassword? confirmPassword,
  }) {
    return AuthFormState(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  @override
  List<Object?> get props => [name, surname, email, password, confirmPassword];

  String? get nameError => name.value.fold(
        (failure) => failure.message,
        (_) => null,
      );

  String? get surnameError => surname.value.fold(
        (failure) => failure.message,
        (_) => null,
      );

  String? get emailError => email.value.fold(
        (failure) => failure.message,
        (_) => null,
      );

  String? get passwordError => password.value.fold(
        (failure) => failure.message,
        (_) => null,
      );

  String? get confirmPasswordError => confirmPassword.value.fold(
        (failure) => failure.message,
        (_) => null,
      );
}

class AuthFormInitial extends AuthFormState {
  AuthFormInitial()
      : super(
          name: Name(''),
          surname: Name(''),
          email: Email(''),
          password: Password(''),
          confirmPassword: ConfirmPassword(
            input: '',
            password: '',
          ),
        );
}
