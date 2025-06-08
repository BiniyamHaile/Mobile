import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/comment/comment.dart';
import 'package:mobile/models/reel/like/like_status.dart';

abstract class CommentState extends Equatable {
  final List<Comment> comments;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  final String? updatedReelId;
  final int? updatedReelCommentCount;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = true,
    this.currentPage = 0,
    this.updatedReelId,
    this.updatedReelCommentCount,
  });

  bool get hasError => errorMessage != null;

  @override
  List<Object?> get props => [
    comments,
    isLoading,
    errorMessage,
    hasMore,
    currentPage,
    updatedReelId,
    updatedReelCommentCount,
  ];
}

class CommentInitial extends CommentState {
  const CommentInitial()
    : super(
        comments: const [],
        isLoading: false,
        errorMessage: null,
        hasMore: true,
        currentPage: 0,
      );
}

class CommentLoading extends CommentState {
  final bool isInitialLoad;

  const CommentLoading({
    required List<Comment> comments,
    required bool hasMore,
    required int currentPage,
    this.isInitialLoad = false,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) : super(
         comments: comments,
         isLoading: true,
         errorMessage: null,
         hasMore: hasMore,
         currentPage: currentPage,
         updatedReelId: updatedReelId,
         updatedReelCommentCount: updatedReelCommentCount,
       );

  @override
  List<Object?> get props => [...super.props, isInitialLoad];
}

class CommentLoaded extends CommentState {
  const CommentLoaded({
    required List<Comment> comments,
    required bool hasMore,
    required int currentPage,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) : super(
         comments: comments,
         isLoading: false,
         errorMessage: null,
         hasMore: hasMore,
         currentPage: currentPage,
         updatedReelId: updatedReelId,
         updatedReelCommentCount: updatedReelCommentCount,
       );

  CommentLoaded copyWith({
    List<Comment>? comments,
    bool? hasMore,
    int? currentPage,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) {
    return CommentLoaded(
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      updatedReelId: updatedReelId ?? this.updatedReelId,
      updatedReelCommentCount:
          updatedReelCommentCount ?? this.updatedReelCommentCount,
    );
  }
}

class CommentError extends CommentState {
  final bool isInitialLoad;

  const CommentError({
    required String message,
    required List<Comment> comments,
    required bool hasMore,
    required int currentPage,
    this.isInitialLoad = false,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) : super(
         comments: comments,
         isLoading: false,
         errorMessage: message,
         hasMore: hasMore,
         currentPage: currentPage,
         updatedReelId: updatedReelId,
         updatedReelCommentCount: updatedReelCommentCount,
       );

  @override
  List<Object?> get props => [...super.props, isInitialLoad];
}

class CommentInteractionSuccess extends CommentState {
  final String commentId;
  final LikeStatus?
  status;

  const CommentInteractionSuccess({
    required this.commentId,
    this.status,
    required List<Comment> comments,
    required bool hasMore,
    required int currentPage,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) : super(
         comments: comments,
         isLoading: false,
         errorMessage: null,
         hasMore: hasMore,
         currentPage: currentPage,
         updatedReelId: updatedReelId,
         updatedReelCommentCount: updatedReelCommentCount,
       );

  @override
  List<Object?> get props => [...super.props, commentId, status];
}

class CommentInteractionFailure extends CommentState {
  final String commentId;
  final String
  errorDetails;

  const CommentInteractionFailure({
    required this.commentId,
    required this.errorDetails,
    required List<Comment> comments,
    required bool hasMore,
    required int currentPage,
    String? updatedReelId,
    int? updatedReelCommentCount,
  }) : super(
         comments: comments,
         isLoading: false,
         errorMessage: errorDetails,
         hasMore: hasMore,
         currentPage: currentPage,
         updatedReelId: updatedReelId,
         updatedReelCommentCount: updatedReelCommentCount,
       );

  @override
  List<Object?> get props => [...super.props, commentId, errorDetails];
}