part of 'usernamesettings_bloc.dart';

@immutable
sealed class UsernamesettingsState {}

final class UsernamesettingsInitial extends UsernamesettingsState {}

final class UsernameUpdateInProgress extends UsernamesettingsState {}

final class UsernameUpdateSuccess extends UsernamesettingsState {}

final class UsernameUpdateFailure extends UsernamesettingsState {
  final String error;
  UsernameUpdateFailure(this.error);
  @override
  List<Object> get props => [error];
}

final class UsernameAvailabilityChecking extends UsernamesettingsState {}
final class UsernameAvailable extends UsernamesettingsState {}
final class UsernameNotAvailable extends UsernamesettingsState {} 