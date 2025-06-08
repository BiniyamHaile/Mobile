part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class LoadComments extends CommentEvent {
  final String postId;

  const LoadComments(this.postId);

  @override
  List<Object> get props => [postId];
}

class CreateComment extends CommentEvent {
  final String postId;
  final String content;
  final String? parentId;
  final List<XFile>? files;
  final List<String>? mentions;

  const CreateComment({
    required this.postId,
    required this.content,
    this.parentId,
    this.files,
    this.mentions,
  });

  @override
  List<Object> get props => [
        postId, 
        content, 
        parentId ?? '', 
        files ?? [], 
        mentions ?? []
      ];
}

class UpdateComment extends CommentEvent {
  final String commentId;
  final String content;
  final List<XFile>? files;
  final List<String>? mentions;

  const UpdateComment({
    required this.commentId,
    required this.content,
    this.files,
    this.mentions,
  });

  @override
  List<Object> get props => [
        commentId, 
        content, 
        files ?? [], 
        mentions ?? []
      ];
}

class DeleteComment extends CommentEvent {
  final String commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object> get props => [commentId];
}


class ToggleReaction extends CommentEvent {
  final String commentId;

  const ToggleReaction({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}