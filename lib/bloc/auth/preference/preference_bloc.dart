import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';

part 'preference_event.dart';
part 'preference_state.dart';

class PreferenceBloc extends Bloc<PreferenceEvent, PreferenceState> {
  PreferenceBloc() : super(PreferenceInitial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<TogglePreference>(_onTogglePreference);
    on<SubmitPreferences>(_onSubmitPreferences);
  }

  Future<void> _onLoadPreferences(
    LoadPreferences event,
    Emitter<PreferenceState> emit,
  ) async {
    emit(PreferencesLoading());
    try {
      // Mock data - replace with actual API call
      final categories = [
        PreferenceCategory(
          id: 'entertainment',
          name: 'Entertainment',
          options: [
            PreferenceOption(id: 'movies', name: 'Movies'),
            PreferenceOption(id: 'tv_shows', name: 'TV Shows'),
            PreferenceOption(id: 'celebrity', name: 'Celebrity News'),
          ],
        ),
        PreferenceCategory(
          id: 'music',
          name: 'Music',
          options: [
            PreferenceOption(id: 'pop', name: 'Pop'),
            PreferenceOption(id: 'rock', name: 'Rock'),
            PreferenceOption(id: 'hiphop', name: 'Hip Hop'),
          ],
        ),
      ];

      emit(PreferencesLoaded(categories: categories));
    } catch (e) {
      emit(PreferencesError(error: 'Failed to load preferences'));
    }
  }

  void _onTogglePreference(
    TogglePreference event,
    Emitter<PreferenceState> emit,
  ) {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedCategories = currentState.categories.map((category) {
        if (category.id == event.categoryId) {
          final updatedOptions = category.options.map((option) {
            if (option.id == event.optionId) {
              return option.copyWith(selected: !option.selected);
            }
            return option;
          }).toList();
          return category.copyWith(options: updatedOptions);
        }
        return category;
      }).toList();

      emit(currentState.copyWith(categories: updatedCategories));
    }
  }

  Future<void> _onSubmitPreferences(
    SubmitPreferences event,
    Emitter<PreferenceState> emit,
  ) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      emit(PreferencesSubmitting(categories: currentState.categories));

      try {
        // Get all selected preference IDs
        final selectedPreferences = currentState.categories
            .expand((category) => category.options)
            .where((option) => option.selected)
            .map((option) => option.id)
            .toList();

        // Make API call to save preferences
        final response = await Dio().post(
          '${ApiEndpoints.baseUrl}/user/preferences',
          data: {
            'preferences': selectedPreferences,
          },
          // options: Options(
          //   headers: {
          //     'Authorization': 'Bearer ${YOUR_AUTH_TOKEN}', // Add if needed
          //     'Content-Type': 'application/json',
          //   },
          // ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(PreferencesSubmitted(selectedPreferences: selectedPreferences));
        } else {
          emit(PreferencesError(
            error: 'Failed to save preferences: ${response.statusMessage}',
            categories: currentState.categories,
          ));
        }
      } on DioException catch (e) {
        emit(PreferencesError(
          error: 'Error: ${e.response?.data?['message'] ?? e.message}',
          categories: currentState.categories,
        ));
      } catch (e) {
        emit(PreferencesError(
          error: 'Unexpected error: ${e.toString()}',
          categories: currentState.categories,
        ));
      }
    }
  }
}
