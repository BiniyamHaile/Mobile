part of 'passwordsettings_bloc.dart';

@immutable
sealed class PasswordsettingsEvent {}

class PasswordChanged extends PasswordsettingsEvent {
  final String currentPassword;
  final String newPassword;

    PasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });
  

  @override
  List<Object> get props => [currentPassword, newPassword];
}
