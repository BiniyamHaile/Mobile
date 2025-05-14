import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/models/comment.dart';
import 'package:mobile/services/api/global/base_repository.dart';

class CommentRepository extends BaseRepository {
  Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      print('Fetching comments for post ID: $postId');
      final response = await get(
        '/social/posts/$postId/comments',
      );

      print('Comments response: $response');

      // First, fetch all top-level comments
      final comments = (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();

      print("after comments: $comments");

      // Then, for each comment, fetch its replies
      for (var comment in comments) {
        if (comment.replies.isNotEmpty) {
          print('Fetching replies for comment ID: ${comment.id}');
          comment.commentRepliesList =
              await getRepliesForComment(comment.replies);
        }
      }

      print("after loop: $comments");

      return comments;
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<List<Comment>> getRepliesForComment(List<String> commentIds) async {
    try {
      print('Fetching replies for comment IDs: $commentIds');

      // Fetch replies for all comment IDs in parallel
      final List<dynamic> responses =
          await Future.wait(commentIds.map((id) async {
        final response = await get('/social/comments/$id');
        return response.data; // Get the actual data from the response
      }));

      print('Replies responses: $responses');

      // Process all responses
      final allReplies = <Comment>[];
      for (var responseData in responses) {
        if (responseData is List) {
          final replies =
              responseData.map((json) => Comment.fromJson(json)).toList();
          allReplies.addAll(replies);

          print("Added ${replies.length} replies");
        } else if (responseData is Map<String, dynamic>) {
          // Handle case where single comment is returned
          allReplies.add(Comment.fromJson(responseData));
          print("Added 1 reply");
        }
      }

      print("Total replies fetched: ${allReplies.length}");
      return allReplies;
    } catch (e) {
      print('Error fetching replies: $e');
      throw Exception('Failed to fetch replies: $e');
    }
  }

  Future<Comment> createComment({
    required String postId,
    required String content,
    String? parentId,
    List<File>? files,
    List<String>? mentions,
  }) async {

      final formData = FormData.fromMap({
        'content': content,
        'postId': postId,
        if (parentId != null) 'parentId': parentId,
        if (mentions != null) 'mentions': mentions,

        if (files != null)
          'files': await Future.wait(
            files.map((file) async => await MultipartFile.fromFile(file.path)),
          ),
      });

      print('Creating comment with formData: $formData');
      
    try {
      final response = await dio.post(
        '/social/comments',
        data: formData,
      );
      print('Response from createComment: ${response}');
      return Comment.fromJson(response.data);
    } catch (e) {
      print('Error creating comment: $e');
      throw Exception('Failed to create comment: $e');
    }
  }

  Future<Comment> updateComment({
    required String commentId,
    required String content,
    List<File>? files,
    List<String>? mentions,
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (files != null)
          'files': await Future.wait(
            files.map((file) async => await MultipartFile.fromFile(file.path)),
          ),
      });

      final response = await dio.patch(
        '/social/comments/$commentId',
        data: formData,
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final response = await delete(
        '/social/comments/$commentId',
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
