import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupEvent>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
      SignupEvent event, Emitter<SignupState> emit) async {
    emit(SignupLoading());
    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/register',
        data: {
          'firstName': event.name,
          'lastName': event.surname,
          'email': event.email,
          'password': event.password,
          'gender': 'male', // or any default
        },
      );

      if (response.statusCode == 201) {
        emit(SignupSuccess(message: 'User registration successful!'));
      } else {
        emit(SignupFailure(error: 'Failed to register user.'));
      }
    } catch (e) {
      emit(SignupFailure(error: 'Error: ${e.toString()}'));
    }
  }
}
