part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserRto user;
  final List<VideoItem> videos;
  final bool isFollowing;
  final List<UserRto> followers;
  final List<UserRto> following;

  ProfileLoaded({
    required this.user,
    required this.videos,
    required this.isFollowing,
    required this.followers,
    required this.following,
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
} 