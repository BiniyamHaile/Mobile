import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/repository/social/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository postRepository;

  PostBloc({required this.postRepository}) : super(PostInitial()) {
    on<FetchPosts>(_onFetchPosts);
    on<CreatePost>(_onCreatePost);
    on<UpdatePost>(_onUpdatePost);
    on<DeletePost>(_onDeletePost);
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
      );
      emit(PostCreationSuccess(createdPost));
    } catch (e) {
      emit(PostCreationFailure(e.toString()));
    }
  }

  Future<void> _onUpdatePost(UpdatePost event, Emitter<PostState> emit) async {
    emit(
        PostCreationLoading()); // You can create a separate UpdateLoading if needed
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

      emit(PostCreationSuccess(updatedPost)); // Or create PostUpdateSuccess
    } catch (e) {
      emit(PostCreationFailure(e.toString())); // Or create PostUpdateFailure
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
}
