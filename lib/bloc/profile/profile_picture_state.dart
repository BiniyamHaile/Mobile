part of 'profile_picture_cubit.dart';

@immutable
abstract class ProfilePictureState {}

class ProfilePictureInitial extends ProfilePictureState {}
class ProfilePictureUploading extends ProfilePictureState {}
class ProfilePictureSuccess extends ProfilePictureState {
  final dynamic user;
  ProfilePictureSuccess(this.user);
}
class ProfilePictureError extends ProfilePictureState {
  final String error;
  ProfilePictureError(this.error);
} 