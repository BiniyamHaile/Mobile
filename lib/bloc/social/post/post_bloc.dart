import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/repository/social/post_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
    on<ToggleReaction>(_onToggleReaction);
  }

  Future<void> _onFetchPosts(FetchPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());
    try {
      final result = await postRepository.fetchPosts(
        limit: event.limit,
        offset: event.offset,
        next: event.next,
        previous: event.previous,
      );
      emit(PostLoaded(posts: result));
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }

  Future<void> _onCreatePost(
    CreatePost event,
    Emitter<PostState> emit,
  ) async {
    emit(PostCreationLoading());
    try {
      List<File> files = [];
      if (event.mediaFiles != null) {
        files = event.mediaFiles!.map((xfile) => File(xfile.path)).toList();
      }

      final createdPost = await postRepository.createPost(
        content: event.content,
        files: files,
        mentions: event.mentions,
      );
      emit(PostCreationSuccess(createdPost));
    } catch (e) {
      emit(PostCreationFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    emit(PostUpdateLoading());
    try {
      List<File> files = [];
      if (event.mediaFiles != null) {
        files = event.mediaFiles!.map((xfile) => File(xfile.path)).toList();
      }

      final updatedPost = await postRepository.updatePost(
        postId: event.postId,
        content: event.content,
        files: files,
      );

      emit(PostUpdateSuccess(updatedPost));
    } catch (e) {
      emit(PostUpdateFailure(e.toString()));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostState> emit) async {
    emit(PostDeleteLoading());
    try {
      await postRepository.deletePost(postId: event.postId);
      emit(PostDeleteSuccess(event.postId));
    } catch (e) {
      emit(PostDeleteFailure(e.toString()));
    }
  }

  Future<void> _onToggleReaction(
    ToggleReaction event,
    Emitter<PostState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId');
    if (state is! PostLoaded) return;
    final currentState = state as PostLoaded;

    final postIndex =
        currentState.posts.data.indexWhere((p) => p.id == event.postId);
    if (postIndex == -1) return;

    final originalPost = currentState.posts.data[postIndex];
    final tempPost = originalPost.copyWith(
      likedBy: List.from(originalPost.likedBy),
    );

    final isLiked = tempPost.likedBy.contains(currentUserId);
    if (isLiked) {
      tempPost.likedBy.remove(currentUserId);
    } else {
      tempPost.likedBy.add(currentUserId!);
    }

    final updatedPosts = List<Post>.from(currentState.posts.data);
    updatedPosts[postIndex] = tempPost;

    emit(PostLoaded(
      posts: FindResult(
        data: updatedPosts,
        total: currentState.posts.total,
      ),
    ));

    try {
      final updatedPost = await postRepository.toggleReaction(
        postId: event.postId,
      );

      updatedPosts[postIndex] = updatedPost;
      emit(PostLoaded(
        posts: FindResult(
          data: updatedPosts,
          total: currentState.posts.total,
        ),
      ));
    } catch (e) {
      updatedPosts[postIndex] = originalPost;
      emit(PostLoaded(
        posts: FindResult(
          data: updatedPosts,
          total: currentState.posts.total,
        ),
      ));

      emit(PostError(message: 'Failed to update like'));
    }
  }
}