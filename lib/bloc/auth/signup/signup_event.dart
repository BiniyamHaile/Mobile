part of 'signup_bloc.dart';

class SignupEvent  {
  final String name;
  final String surname;
  final String email;
  final String password;
  final String gender;

  const SignupEvent({
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.gender
  });

}
