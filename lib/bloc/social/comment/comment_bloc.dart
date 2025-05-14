import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/models/comment.dart';
import 'package:mobile/repository/social/comment_repository.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _commentRepository;

  CommentBloc({required CommentRepository commentRepository})
      : _commentRepository = commentRepository,
        super(CommentInitial()) {
    on<LoadComments>(_onLoadComments);
    on<CreateComment>(_onCreateComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      final comments =
          await _commentRepository.getCommentsForPost(event.postId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommentError('Failed to load comments: $e'));
      emit(CommentInitial());
    }
  }

  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      // Get current comments from any valid state
      List<Comment> currentComments;
      if (state is CommentsLoaded) {
        currentComments = (state as CommentsLoaded).comments;
      } else if (state is CommentOperationSuccess) {
        currentComments = (state as CommentOperationSuccess).comments;
      } else {
        currentComments = [];
      }

      emit(CommentLoading(currentComments));

      List<File> filess = [];
      if (event.files != null) {
        filess = event.files!.map((xfile) => File(xfile.path)).toList();
      }
      print(
        'Creating comment with content: ${event.content}, postId: ${event.postId}, parentId: ${event.parentId}, files: $filess, mentions: ${event.mentions}',
      );
      final newComment = await _commentRepository.createComment(
        postId: event.postId,
        content: event.content,
        parentId: event.parentId,
        files: filess,
        mentions: event.mentions,
      );

      final updatedComments = [...currentComments, newComment];
      emit(CommentsLoaded(updatedComments));
      emit(CommentOperationSuccess(
        comments: updatedComments,
        message: 'Comment created successfully',
      ));
    } catch (e) {
      emit(CommentError('Failed to create comment: $e', state.comments));
      if (state is CommentOperationSuccess || state is CommentsLoaded) {
        emit(state);
      } else {
        emit(CommentInitial());
      }
    }
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      // Get current comments from any valid state
      List<Comment> currentComments;
      if (state is CommentsLoaded) {
        currentComments = (state as CommentsLoaded).comments;
      } else if (state is CommentOperationSuccess) {
        currentComments = (state as CommentOperationSuccess).comments;
      } else {
        currentComments = [];
      }

      emit(CommentLoading(currentComments));

      List<File> filess = [];
      if (event.files != null) {
        filess = event.files!.map((xfile) => File(xfile.path)).toList();
      }

      final updatedComment = await _commentRepository.updateComment(
        commentId: event.commentId,
        content: event.content,
        files: filess,
        mentions: event.mentions,
      );

      final updatedComments = currentComments
          .map((comment) =>
              comment.id == event.commentId ? updatedComment : comment)
          .toList();

      emit(CommentsLoaded(updatedComments));
      emit(CommentOperationSuccess(
        comments: updatedComments,
        message: 'Comment updated successfully',
      ));
    } catch (e) {
      emit(CommentError('Failed to update comment: $e', state.comments));
      if (state is CommentOperationSuccess || state is CommentsLoaded) {
        emit(state);
      } else {
        emit(CommentInitial());
      }
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      // Get current comments from any valid state
      List<Comment> currentComments;
      if (state is CommentsLoaded) {
        currentComments = (state as CommentsLoaded).comments;
      } else if (state is CommentOperationSuccess) {
        currentComments = (state as CommentOperationSuccess).comments;
      } else {
        currentComments = [];
      }

      emit(CommentLoading(currentComments));

      final success = await _commentRepository.deleteComment(event.commentId);
      if (!success) throw Exception('Delete operation failed');

      final updatedComments = currentComments
          .where((comment) => comment.id != event.commentId)
          .toList();

      emit(CommentsLoaded(updatedComments));
      emit(CommentOperationSuccess(
        comments: updatedComments,
        message: 'Comment deleted successfully',
      ));
    } catch (e) {
      emit(CommentError('Failed to delete comment: $e', state.comments));
      if (state is CommentOperationSuccess || state is CommentsLoaded) {
        emit(state);
      } else {
        emit(CommentInitial());
      }
    }
  }
}
