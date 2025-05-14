part of 'preference_bloc.dart';

@immutable
sealed class PreferenceEvent extends Equatable {
  const PreferenceEvent();

  @override
  List<Object> get props => [];
}

class LoadPreferences extends PreferenceEvent {}

class TogglePreference extends PreferenceEvent {
  final String categoryId;
  final String optionId;

  const TogglePreference({required this.categoryId, required this.optionId});

  @override
  List<Object> get props => [categoryId, optionId];
}

class SubmitPreferences extends PreferenceEvent {}
