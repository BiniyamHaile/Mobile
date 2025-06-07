import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/models/comment.dart';
import 'package:mobile/services/api/global/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentRepository extends BaseRepository {
  Future<List<Comment>> getCommentsForPost(String postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      final response = await get(
        '/social/posts/$postId/comments',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      // First, fetch all top-level comments
      final comments = (response.data as List)
          .map((json) => Comment.fromJson(json))
          .toList();

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
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      final List<dynamic> responses =
          await Future.wait(commentIds.map((id) async {
        final response = await get(
          '/social/comments/$id',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data'
          }),
        );
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
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
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
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
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
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update comment: $e');
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await dio.delete(
        '/social/comments/$commentId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<Comment> toggleReaction(String commentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await dio.post(
        '/social/comments/$commentId/toggleReaction',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to toggle reaction: $e');
    }
  }
}
