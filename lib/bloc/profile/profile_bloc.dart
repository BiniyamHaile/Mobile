import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/models/user/user_rto.dart';
import 'package:mobile/services/api/profile/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<FollowUser>(_onFollowUser);
    on<UnfollowUser>(_onUnfollowUser);
    on<LoadUserVideos>(_onLoadUserVideos);
    on<LoadFollowers>(_onLoadFollowers);
    on<LoadFollowing>(_onLoadFollowing);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _profileRepository.getUserProfile();
      final videos = await _profileRepository.getUserVideos();
      final isFollowing = await _profileRepository.checkFollowStatus(user.id);
      final followers = await _profileRepository.getFollowers();
      final following = await _profileRepository.getFollowing();
      
      emit(ProfileLoaded(
        user: user,
        videos: videos,
        isFollowing: isFollowing,
        followers: followers,
        following: following,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        await _profileRepository.followUser(event.targetId);
        emit(ProfileLoaded(
          user: currentState.user,
          videos: currentState.videos,
          isFollowing: true,
          followers: currentState.followers,
          following: currentState.following,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUnfollowUser(
    UnfollowUser event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        await _profileRepository.unfollowUser(event.targetId);
        emit(ProfileLoaded(
          user: currentState.user,
          videos: currentState.videos,
          isFollowing: false,
          followers: currentState.followers,
          following: currentState.following,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserVideos(
    LoadUserVideos event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        final videos = await _profileRepository.getUserVideos();
        emit(ProfileLoaded(
          user: currentState.user,
          videos: videos,
          isFollowing: currentState.isFollowing,
          followers: currentState.followers,
          following: currentState.following,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLoadFollowers(
    LoadFollowers event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        final followers = await _profileRepository.getFollowers();
        emit(ProfileLoaded(
          user: currentState.user,
          videos: currentState.videos,
          isFollowing: currentState.isFollowing,
          followers: followers,
          following: currentState.following,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onLoadFollowing(
    LoadFollowing event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        final following = await _profileRepository.getFollowing();
        emit(ProfileLoaded(
          user: currentState.user,
          videos: currentState.videos,
          isFollowing: currentState.isFollowing,
          followers: currentState.followers,
          following: following,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
} 