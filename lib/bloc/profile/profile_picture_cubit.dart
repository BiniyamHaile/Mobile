import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_picture_state.dart';

class ProfilePictureCubit extends Cubit<ProfilePictureState> {
  ProfilePictureCubit() : super(ProfilePictureInitial());

  Future<void> uploadProfilePicture(String filePath) async {
    emit(ProfilePictureUploading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProfilePictureError('Authentication required. Please login again.'));
        return;
      }
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/auth/upload-profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      if (response.statusCode == 201) {
        emit(ProfilePictureSuccess(response.data['user']));
      } else {
        emit(ProfilePictureError('Failed to upload profile picture.'));
      }
    } catch (e) {
      emit(ProfilePictureError('Failed to upload profile picture.'));
    }
  }
} 