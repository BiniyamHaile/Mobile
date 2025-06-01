import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc() : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpResendRequested>(_onOtpResendRequested);
  }

  Future<void> _onOtpSubmitted(
      OtpSubmitted event, Emitter<OtpState> emit) async {
    emit(OtpLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/verifyEmail',
        data: {
          'email': event.email,
          'verificationCode': event.code,
        },
      );

      if (response.statusCode == 201) {
        emit(OtpSuccess(message: 'Email verification successful!'));
      } else {
        emit(OtpFailure(error: 'Failed to verify email.'));
      }
    } catch (e) {
      emit(OtpFailure(error: 'Error: ${e.toString()}'));
    }
  }

    Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/resend-otp',
        data: {
          'email': event.email,
        },
      );
      if (response.statusCode == 201) {
        emit(OtpSuccess(message: 'OTP resent successfully!'));
      } else {
        emit(OtpFailure(error: 'Failed to resend OTP.'));
      }
    } catch (e) {
      emit(OtpFailure(error: 'Error: ${e.toString()}'));
    }
  }
}
