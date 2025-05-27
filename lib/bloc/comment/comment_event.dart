import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/comment/dto/create_comment_dto.dart';
import 'package:mobile/models/reel/comment/dto/update_comment_dto.dart';
import 'package:mobile/models/reel/like/like_dto.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => []; 
}

class LoadCommentsForReel extends CommentEvent {
  final String reelId;
  final int page;
  final int limit;

  const LoadCommentsForReel({
    required this.reelId,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [reelId, page, limit]; 
}

class PostComment extends CommentEvent {
  final CreateCommentDto commentData;
  final String reelId;

  const PostComment({
    required this.commentData,
    required this.reelId,
  });

  @override
  List<Object?> get props => [commentData, reelId]; 
}

class UpdateComment extends CommentEvent {
  final String commentId;
  final UpdateCommentDto updateData;
  final String reelId;

  const UpdateComment({
    required this.commentId,
    required this.updateData,
    required this.reelId,
  });

  @override
  List<Object?> get props => [commentId, updateData, reelId]; 
}

class DeleteComment extends CommentEvent {
  final String commentId;
  final String reelId;

  const DeleteComment({
    required this.commentId,
    required this.reelId,
  });

  @override
  List<Object?> get props => [commentId, reelId]; 
}

class LikeComment extends CommentEvent {
  final CreateLikeDto likeData;

  const LikeComment({required this.likeData});

  @override
  List<Object?> get props => [likeData]; 
}