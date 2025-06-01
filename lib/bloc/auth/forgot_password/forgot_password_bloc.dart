import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
  }

  Future<void> _onForgotPasswordSubmitted(
      ForgotPasswordSubmitted event, Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/forgot-password',
        data: {
          'email': event.email,
        },
      );

      if (response.statusCode == 201) {
        emit(ForgotPasswordSuccess(
            message:
            'Password reset code sent to your email. Please check your inbox.'));
      } else {
        emit(ForgotPasswordFailure(error:
            'Failed to send reset code. Please try again.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(ForgotPasswordFailure(error: 'User not found with this email address'));
      } else {
        emit(ForgotPasswordFailure(error: 'Network error. Please try again.'));
      }
    } catch (e) {
      emit(ForgotPasswordFailure(error: 'An unexpected error occurred'));
    }
  }
}
