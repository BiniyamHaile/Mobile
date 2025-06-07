import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/value_objects/auth/confirm_password.dart';
import 'package:mobile/core/value_objects/auth/email.dart';
import 'package:mobile/core/value_objects/auth/name.dart';
import 'package:mobile/core/value_objects/auth/password.dart';

part 'auth_form_event.dart';
part 'auth_form_state.dart';

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc() : super(AuthFormInitial()) {
    on<NameChanged>(_onNameChanged);
    on<SurnameChanged>(_onSurnameChanged);
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
  }

  void _onNameChanged(NameChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(name: Name(event.name)));
  }

  void _onSurnameChanged(SurnameChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(surname: Name(event.surname)));
  }

  void _onEmailChanged(EmailChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(email: Email(event.email)));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(password: Password(event.password)));
  }

  void _onConfirmPasswordChanged(
      ConfirmPasswordChanged event, Emitter<AuthFormState> emit) {
    emit(state.copyWith(
      confirmPassword: ConfirmPassword(
        input: event.confirmPassword,
        password: event.password,
      ),
    ));
  }
}
