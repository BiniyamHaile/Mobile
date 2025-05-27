part of 'preference_bloc.dart';

@immutable
sealed class PreferenceState extends Equatable {
  const PreferenceState();

  @override
  List<Object> get props => [];
}

class PreferenceInitial extends PreferenceState {}

class PreferencesLoading extends PreferenceState {}

class PreferencesLoaded extends PreferenceState {
  final List<PreferenceCategory> categories;

  const PreferencesLoaded({required this.categories});

  PreferencesLoaded copyWith({List<PreferenceCategory>? categories}) {
    return PreferencesLoaded(
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object> get props => [categories];
}

class PreferencesSubmitting extends PreferenceState {
  final List<PreferenceCategory> categories;

  const PreferencesSubmitting({required this.categories});

  @override
  List<Object> get props => [categories];
}

class PreferencesSubmitted extends PreferenceState {
  final List<String> selectedPreferences;

  const PreferencesSubmitted({required this.selectedPreferences});

  @override
  List<Object> get props => [selectedPreferences];
}

class PreferencesError extends PreferenceState {
  final String error;
  final List<PreferenceCategory>? categories;

  const PreferencesError({
    required this.error,
    this.categories,
  });

  @override
  List<Object> get props => [error, if (categories != null) categories!];
}

class PreferenceCategory extends Equatable {
  final String id;
  final String name;
  final List<PreferenceOption> options;

  const PreferenceCategory({
    required this.id,
    required this.name,
    required this.options,
  });

  PreferenceCategory copyWith({
    String? id,
    String? name,
    List<PreferenceOption>? options,
  }) {
    return PreferenceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      options: options ?? this.options,
    );
  }

  @override
  List<Object> get props => [id, name, options];
}

class PreferenceOption extends Equatable {
  final String id;
  final String name;
  final bool selected;

  const PreferenceOption({
    required this.id,
    required this.name,
    this.selected = false,
  });

  PreferenceOption copyWith({
    String? id,
    String? name,
    bool? selected,
  }) {
    return PreferenceOption(
      id: id ?? this.id,
      name: name ?? this.name,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object> get props => [id, name, selected];
}
