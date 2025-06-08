import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'usernamesettings_event.dart';
part 'usernamesettings_state.dart';

class UsernamesettingsBloc extends Bloc<UsernamesettingsEvent, UsernamesettingsState> {
  UsernamesettingsBloc() : super(UsernamesettingsInitial()) {
    on<UsernameChanged>(_onUsernameChanged);
    on<UsernameAvailabilityChecked>(_onUsernameAvailabilityChecked);
  }

  Future<void> _onUsernameChanged(
    UsernameChanged event,
    Emitter<UsernamesettingsState> emit,
  ) async {
    emit(UsernameUpdateInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(UsernameUpdateFailure('Authentication required. Please login again.'));
        return;
      }
      final response = await Dio().put(
        '${ApiEndpoints.baseUrl}/auth/update-username',
        data: {
          'username': event.newUsername,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        emit(UsernameUpdateSuccess());
      } else {
        emit(UsernameUpdateFailure('Username update failed. Please try again.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(UsernameUpdateFailure('Authentication error.'));
      } else if (e.response?.statusCode == 400) {
        emit(UsernameUpdateFailure('Username is not available.'));
      } else {
        emit(UsernameUpdateFailure('Network error. Please try again.'));
      }
    } catch (e) {
      emit(UsernameUpdateFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onUsernameAvailabilityChecked(
    UsernameAvailabilityChecked event,
    Emitter<UsernamesettingsState> emit,
  ) async {
    emit(UsernameAvailabilityChecking());
    try {
      final response = await Dio().get(
        '${ApiEndpoints.baseUrl}/auth/check-username/${event.username}',
      );
      if (response.statusCode == 200 && response.data['available'] == true) {
        emit(UsernameAvailable());
      } else {
        emit(UsernameNotAvailable());
      }
    } catch (e) {
      emit(UsernameNotAvailable());
    }
  }
} 