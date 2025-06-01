import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onResetPasswordSubmitted);
  }

  Future<void> _onResetPasswordSubmitted(
      ResetPasswordSubmitted event, Emitter<ResetPasswordState> emit) async {
    emit(ResetPasswordLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/reset-password',
        data: {
          'email': event.email,
          'resetCode': event.resetCode,
          'newPassword': event.newPassword,
        },
      );

      if (response.statusCode == 201) {
        emit(ResetPasswordSuccess(message: 'Password reset successful!'));
      } else {
        emit(ResetPasswordFailure(error: 'Failed to reset password.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        emit(ResetPasswordFailure(error: 'Invalid or expired reset code'));
      } else if (e.response?.statusCode == 404) {
        emit(ResetPasswordFailure(error: 'User not found'));
      } else {
        emit(ResetPasswordFailure(error: 'Error: ${e.message}'));
      }
    } catch (e) {
      emit(ResetPasswordFailure(error: 'Error: ${e.toString()}'));
    }
  }
}
