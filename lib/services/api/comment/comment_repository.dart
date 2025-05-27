import 'package:mobile/models/reel/comment/dto/create_comment_dto.dart';
import 'package:mobile/models/reel/comment/dto/delete_comment_response_dto.dart';
import 'package:mobile/models/reel/comment/dto/update_comment_dto.dart';

import '../../../models/reel/comment/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentsForReel({
    required String reelId,
    required int page,
    required int limit,
  });

  Future<Comment> postComment({required CreateCommentDto commentData});

  Future<void> updateComment({
    required String commentId,
    required UpdateCommentDto updateData,
  });

  Future<DeleteCommentResponseDto> deleteComment({required String commentId});
}
