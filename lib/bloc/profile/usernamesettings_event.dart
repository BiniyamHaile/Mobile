part of 'usernamesettings_bloc.dart';

@immutable
sealed class UsernamesettingsEvent {}

class UsernameChanged extends UsernamesettingsEvent {
  final String newUsername;
  UsernameChanged({required this.newUsername});
  @override
  List<Object> get props => [newUsername];
}

class UsernameAvailabilityChecked extends UsernamesettingsEvent {
  final String username;
  UsernameAvailabilityChecked({required this.username});
  @override
  List<Object> get props => [username];
} 