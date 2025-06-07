import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/models/reel/comment/comment.dart';
import 'package:mobile/models/reel/comment/dto/delete_comment_response_dto.dart';
import 'package:mobile/models/reel/like/like_reel_response_dto.dart';
import 'package:mobile/models/reel/like/like_status.dart';
import 'package:mobile/services/api/comment/comment_repository.dart';
import 'package:mobile/services/api/reel/reel_repository.dart';

import 'comment_event.dart';
import 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _commentRepository;
  final ReelRepository
  _reelRepository; 

  final int _defaultLimit = 10;

  CommentBloc(
    this._commentRepository,
    this._reelRepository,
  ) 
  : super(const CommentInitial()) {
    on<LoadCommentsForReel>(_onLoadCommentsForReel);
    on<PostComment>(_onPostComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<LikeComment>(_onLikeComment);
  }

  Future<void> _onLoadCommentsForReel(
    LoadCommentsForReel event,
    Emitter<CommentState> emit,
  ) async {
    final isFirstPageForReel =
        state.comments.isEmpty ||
        (state.comments.isNotEmpty &&
            state.comments.first.reelId != event.reelId) ||
        event.page == 1;

    if (state.isLoading && !isFirstPageForReel) {
      print(
        "Already loading, ignoring load request for reel ${event.reelId}, page ${event.page}",
      );
      return;
    }

    final loadingComments =
        isFirstPageForReel
            ? <Comment>[]
            : List<Comment>.unmodifiable(state.comments);

    emit(
      CommentLoading(
        comments: loadingComments,
        hasMore: isFirstPageForReel ? true : state.hasMore,
        currentPage: state.currentPage,
        isInitialLoad: isFirstPageForReel,
      ),
    );

    try {
      final comments = await _commentRepository.getCommentsForReel(
        reelId: event.reelId,
        page: event.page,
        limit: event.limit,
      );

      final updatedComments =
          isFirstPageForReel
              ? List<Comment>.unmodifiable(comments)
              : List<Comment>.unmodifiable([...state.comments, ...comments]);

      final hasMore = comments.length == event.limit;

      emit(
        CommentLoaded(
          comments: updatedComments,
          hasMore: hasMore,
          currentPage: event.page,
        ),
      );
    } catch (e) {
      final errorMessage =
          'Failed to load comments (page ${event.page}, limit ${event.limit}) for reel ${event.reelId}: ${e.toString()}';
      final errorComments =
          isFirstPageForReel
              ? <Comment>[]
              : List<Comment>.unmodifiable(state.comments);

      emit(
        CommentError(
          message: errorMessage,
          comments: errorComments,
          hasMore: isFirstPageForReel ? false : state.hasMore,
          currentPage: state.currentPage,
          isInitialLoad: isFirstPageForReel,
        ),
      );
    }
  }

  Future<void> _onPostComment(
    PostComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(
      CommentLoading(
        comments: List<Comment>.from(state.comments),
        hasMore: state.hasMore,
        currentPage: state.currentPage,
        isInitialLoad: false,
      ),
    );
    try {
      final Comment newComment = await _commentRepository.postComment(
        commentData: event.commentData,
      );

      List<Comment> currentComments = state.comments;
      List<Comment> updatedComments = List<Comment>.from(currentComments);

      if (currentComments.isEmpty ||
          currentComments.first.reelId == newComment.reelId) {
        updatedComments.insert(0, newComment); 
        print(
          "Successfully posted and optimistically added comment for reel ${newComment.reelId}.",
        );
      } else {
        print(
          "Posted comment for reel ${newComment.reelId}, but current state is for a different reel (${currentComments.isNotEmpty ? currentComments.first.reelId : 'empty list'}). Skipping local list update.",
        );
        updatedComments = List<Comment>.from(currentComments);
      }

      emit(
        CommentLoaded(
          comments: List.unmodifiable(updatedComments), 
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          updatedReelId: newComment.reelId, 
          updatedReelCommentCount: newComment.reelCommentCount, 
        ),
      );
    } catch (e) {
      emit(
        CommentError(
          message: 'Failed to post comment: ${e.toString()}',
          comments: List<Comment>.from(state.comments),
          hasMore: state.hasMore,
          currentPage: state.currentPage,
        ),
      );
    }
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(
      CommentLoading(
        comments: List<Comment>.from(state.comments), 
        hasMore: state.hasMore, 
        currentPage: state.currentPage, 
        isInitialLoad: false, 
      ),
    );
    try {
      await _commentRepository.updateComment(
        commentId: event.commentId,
        updateData: event.updateData,
      );

      if (state.comments.isNotEmpty &&
          state.comments.first.reelId == event.reelId) {
        add(
          LoadCommentsForReel(
            reelId: event.reelId,
            page: 1, 
            limit:
                state.comments.length > _defaultLimit
                    ? state.comments.length
                    : _defaultLimit, 
          ),
        );
      } else {
        emit(
          CommentLoaded(
            comments: List<Comment>.from(state.comments),
            hasMore: state.hasMore,
            currentPage: state.currentPage,
          ),
        );
        print(
          "Updated comment for a reel not currently displayed. State list unchanged.",
        );
      }

    } catch (e) {
      emit(
        CommentError(
          message: 'Failed to update comment: ${e.toString()}',
          comments: List<Comment>.from(state.comments),
          hasMore: state.hasMore,
          currentPage: state.currentPage,
        ),
      );
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(
      CommentLoading(
        comments: List<Comment>.from(state.comments),
        hasMore: state.hasMore,
        currentPage: state.currentPage,
        isInitialLoad: false,
      ),
    );
    try {
     
      final DeleteCommentResponseDto deleteResponse = await _commentRepository
          .deleteComment(commentId: event.commentId);

      debugPrint("why there is error ${deleteResponse.toString()}");

      debugPrint(deleteResponse.toString());
      final String deletedReelId = deleteResponse.deletedCommentReelId;
      final int newReelCommentCount = deleteResponse.newReelCommentCount;

      List<Comment> currentComments = state.comments;
      List<Comment> updatedComments = List<Comment>.from(currentComments);

      if (currentComments.isNotEmpty &&
          currentComments.first.reelId == event.reelId) {
        final originalLength = updatedComments.length;
        updatedComments.removeWhere((comment) => comment.id == event.commentId);
        if (updatedComments.length < originalLength) {
          print(
            "Successfully deleted and optimistically removed comment with ID ${event.commentId} for reel ${event.reelId}.",
          );
        } else {
          print(
            "Comment with ID ${event.commentId} not found in current list for reel ${event.reelId}.",
          );
        }
      } else {
        print(
          "Deleted comment with ID ${event.commentId} for reel ${event.reelId}, but current state is for a different reel or empty. Skipping local list update.",
        );
        updatedComments = List<Comment>.from(
          currentComments,
        ); 
      }

      emit(
        CommentLoaded(
          comments: List.unmodifiable(updatedComments),
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          updatedReelId: deletedReelId,
          updatedReelCommentCount: newReelCommentCount,
        ),
      );
    } catch (e) {
      emit(
        CommentError(
          message: 'Failed to delete comment: ${e.toString()}',
          comments: List<Comment>.from(state.comments),
          hasMore: state.hasMore,
          currentPage: state.currentPage,
        ),
      );
    }
  }

  int get _nextPage => state.currentPage + 1;
  int get _nextLimit => _defaultLimit;

  void loadInitialComments(String reelId) {
    if (!state.isLoading ||
        (state.comments.isNotEmpty && state.comments.first.reelId != reelId)) {
      add(LoadCommentsForReel(reelId: reelId, page: 1, limit: _defaultLimit));
    } else {
      print(
        "Load initial comments for $reelId ignored: isLoading=${state.isLoading}, current reel=${state.comments.isNotEmpty ? state.comments.first.reelId : 'empty'}",
      );
    }
  }

  void loadNextPage(String reelId) {
    if (!state.isLoading &&
        state.hasMore &&
        state.comments.isNotEmpty &&
        state.comments.first.reelId == reelId) {
      add(
        LoadCommentsForReel(reelId: reelId, page: _nextPage, limit: _nextLimit),
      );
    } else if (state.comments.isNotEmpty &&
        state.comments.first.reelId != reelId) {
      print(
        "Ignoring loadNextPage for reel $reelId - current state is for reel ${state.comments.first.reelId}",
      );
    } else {
      print(
        "Ignoring loadNextPage for reel $reelId - isLoading: ${state.isLoading}, hasMore: ${state.hasMore}, comments empty or different reel",
      );
    }
  }

  Future<void> _onLikeComment(
    LikeComment event,
    Emitter<CommentState> emit,
  ) async {
    emit(
      CommentLoading(
        comments: List<Comment>.from(
          state.comments,
        ), 
        hasMore: state.hasMore, 
        currentPage: state.currentPage, 
        isInitialLoad: false, 
      ),
    );

    try {
      final LikeReelResponseDto response = await _reelRepository.like(
        likeData: event.likeData,
      );

      print(
        'Comment like/unlike operation successful for comment ID ${event.likeData.targetId}. Status: ${response.status}, New Count: ${response.likeCount}',
      );

      final currentComments = List<Comment>.from(state.comments);
      final commentIndex = currentComments.indexWhere(
        (c) => c.id == event.likeData.targetId,
      );

      List<Comment> updatedComments = List<Comment>.from(currentComments);

      if (commentIndex != -1) {
        final oldComment = currentComments[commentIndex];

        final bool newIsLiked = (response.status == LikeStatus.liked);
        final int newLikeCount = response.likeCount;

        final updatedComment = oldComment.copyWith(
          isLiked: newIsLiked,
          likes: newLikeCount,
        );

        updatedComments[commentIndex] = updatedComment;

        print(
          "Optimistically updated comment ${event.likeData.targetId}: isLiked = $newIsLiked, likes = $newLikeCount",
        );

        emit(
          CommentLoaded(
            comments: List<Comment>.unmodifiable(updatedComments),
            hasMore: state.hasMore,
            currentPage: state.currentPage,
          ),
        );
      } else {
        print(
          "Comment ${event.likeData.targetId} not found in current list for optimistic update.",
        );
        emit(
          CommentInteractionSuccess(
            commentId: event.likeData.targetId,
            status: response.status,
            comments: List<Comment>.from(
              state.comments,
            ), 
            hasMore: state.hasMore, 
            currentPage: state.currentPage, 
          ),
        );
      }
    } catch (e) {
      print('Error during LikeComment operation: $e');

      emit(
        CommentInteractionFailure(
          commentId:
              event.likeData.targetId, 
          errorDetails: 'Failed to like/unlike comment: ${e.toString()}',
          comments: List<Comment>.from(state.comments), 
          hasMore: state.hasMore,
          currentPage: state.currentPage,
        ),
      );
    }
  }
}
