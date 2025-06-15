part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class FollowUser extends ProfileEvent {
  final String targetId;

  FollowUser(this.targetId);
}

class UnfollowUser extends ProfileEvent {
  final String targetId;

  UnfollowUser(this.targetId);
}

class LoadUserVideos extends ProfileEvent {
  final String userId;

  LoadUserVideos(this.userId);
}

class LoadFollowers extends ProfileEvent {}

class LoadFollowing extends ProfileEvent {} 