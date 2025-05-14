import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/login',
        data: {
          'email': event.email,
          'password': event.password,
        },
      );

      if (response.statusCode == 201) {
        // Handle successful login
        // You might want to save the token and user data here
        final token = response.data['accessToken'] as String?;
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
        }
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Login failed. Please try again.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (e.response?.data?.contains('verify your email') ?? false) {
          emit(LoginFailure(error: 'Please verify your email first'));
        } else {
          emit(LoginFailure(error: 'Invalid email or password'));
        }
      } else if (e.response?.statusCode == 404) {
        emit(LoginFailure(error: 'User not found'));
      } else {
        emit(LoginFailure(error: 'Network error. Please try again.'));
      }
    } catch (e) {
      emit(LoginFailure(error: 'An unexpected error occurred'));
    }
  }
}
