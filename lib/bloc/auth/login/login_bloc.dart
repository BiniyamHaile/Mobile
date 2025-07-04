import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/injections/get_it.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/services/socket/websocket-service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> connectSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final Map<String, dynamic> data = json.decode(payload);

    getIt<WebSocketService>().connect(data['userId']);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {  
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/login',
        data: {'email': event.email, 'password': event.password},
      );

      print("Response: ${response.data}");

      if (response.statusCode == 201) {
        final token = response.data['accessToken'] as String?;

        print("Token:${response}");

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('token', token);
          await prefs.setString("userId", response.data['userId']);
        }
        await connectSocket();
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(error: 'Login failed. Please try again.'));
      }
    } on DioException catch (e) {
      print(e.response?.statusCode);
      if (e.response?.statusCode == 401) {
        final dynamic responseData = 
        e.response?.data;

        String errorMessageForUser = 'Invalid password';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message') &&
            responseData['message'] is String) {
          final String apiMessage =
           responseData['message'] as String;

          if (apiMessage.contains('verify your email')) {
            errorMessageForUser = 'Please verify your email first';
          } else {
            errorMessageForUser = apiMessage;
          }
        }
        emit(LoginFailure(error: errorMessageForUser));
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
