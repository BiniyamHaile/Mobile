part of 'passwordsettings_bloc.dart';

@immutable
sealed class PasswordsettingsState {}

final class PasswordsettingsInitial extends PasswordsettingsState {}

final class PasswordUpdateInProgress extends PasswordsettingsState {}

final class PasswordUpdateSuccess extends PasswordsettingsState {}

final class PasswordUpdateFailure extends PasswordsettingsState {
  final String error;

  PasswordUpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}
