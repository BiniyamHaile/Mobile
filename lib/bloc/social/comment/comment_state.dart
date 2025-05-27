part of 'comment_bloc.dart';

abstract class CommentState extends Equatable {
  const CommentState();
  
  List<Comment> get comments => const [];
  
  @override
  List<Object> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {
  final List<Comment> previousComments;
  
  const CommentLoading([this.previousComments = const []]);
  
  @override
  List<Comment> get comments => previousComments;
  
  @override
  List<Object> get props => [previousComments];
}

class CommentsLoaded extends CommentState {
  final List<Comment> comments;
  
  const CommentsLoaded(this.comments);
  
  @override
  List<Object> get props => [comments];
}

class CommentOperationSuccess extends CommentState {
  final List<Comment> comments;
  final String message;
  
  const CommentOperationSuccess({
    required this.comments,
    this.message = '',
  });
  
  @override
  List<Object> get props => [comments, message];
}

class CommentError extends CommentState {
  final String message;
  final List<Comment> previousComments;
  
  const CommentError(this.message, [this.previousComments = const []]);
  
  @override
  List<Comment> get comments => previousComments;
  
  @override
  List<Object> get props => [message, previousComments];
}