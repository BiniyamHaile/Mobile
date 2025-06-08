import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'passwordsettings_event.dart';
part 'passwordsettings_state.dart';

class PasswordsettingsBloc
    extends Bloc<PasswordsettingsEvent, PasswordsettingsState> {
  PasswordsettingsBloc() : super(PasswordsettingsInitial()) {
    on<PasswordChanged>(_onPasswordChanged);
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<PasswordsettingsState> emit,
  ) async {
    emit(PasswordUpdateInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PasswordUpdateFailure(
            'Authentication required. Please login again.'));
        return;
      }

      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/change-password',
        data: {
          'currentPassword': event.currentPassword,
          'newPassword': event.newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        emit(PasswordUpdateSuccess());
      } else {
        emit(
            PasswordUpdateFailure('Password update failed. Please try again.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        emit(PasswordUpdateFailure('R'));
      } else if (e.response?.statusCode == 400) {
        emit(PasswordUpdateFailure(
            'New password must be different from current password'));
      } else {
        emit(PasswordUpdateFailure('Network error. Please try again.'));
      }
    } catch (e) {
      emit(PasswordUpdateFailure('An unexpected error occurred'));
    }
  }
}
