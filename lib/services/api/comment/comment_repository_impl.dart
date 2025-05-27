import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/reel/comment/dto/create_comment_dto.dart';
import 'package:mobile/models/reel/comment/dto/delete_comment_response_dto.dart';
import 'package:mobile/models/reel/comment/dto/update_comment_dto.dart';
import 'package:mobile/services/api/comment/comment_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/reel/comment/comment.dart';

class CommentRepositoryImpl implements CommentRepository {
  final Dio _dio;
  ApiEndpoints apiEndpoints;

  CommentRepositoryImpl({Dio? dio , required this.apiEndpoints}) : _dio = dio ?? Dio();

  @override
  Future<List<Comment>> getCommentsForReel({
    required String reelId,
    required int page,
    required int limit,
  }) async {
    print(
      'Attempting to fetch comments for reel ID: $reelId, page: $page, limit: $limit',
    );
    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');
      
      final response = await _dio.get(
        '${apiEndpoints.reelComment}/$reelId',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200) {
        print(
          'Fetch comments failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to fetch comments for reel $reelId (page $page, limit $limit): ${response.statusCode} ${response.statusMessage}',
        );
      }

      final List<dynamic> commentsJson = response.data;

      print("commentsJson ${commentsJson}");

      final List<Comment> comments =
          commentsJson.map((json) => Comment.fromJson(json)).toList();

      print(
        'Successfully fetched ${comments.length} comments for reel $reelId (page $page, limit $limit)',
      );
      return comments;
    } on DioException catch (e) {
      print(
        'Dio error fetching comments for reel $reelId (page $page, limit $limit): ${e.type} - ${e.message}',
      );
      String errorMessage =
          'Failed to fetch comments for reel $reelId (page $page, limit $limit).'; // Update error message
      if (e.response != null) {
        errorMessage =
            'Failed to fetch comments: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
        if (e.response?.statusCode == 400) {
          errorMessage =
              'Invalid pagination parameters provided for reel $reelId.';
          if (e.response?.data != null &&
              e.response!.data is Map &&
              e.response!.data['message'] != null) {
            errorMessage += ' Backend message: ${e.response!.data['message']}';
          }
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Throwing error: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print(
        'Unknown error fetching comments for reel $reelId (page $page, limit $limit): ${e.runtimeType} - $e',
      );
      throw Exception(
        'An unexpected error occurred while fetching comments for reel $reelId (page $page, limit $limit).',
      );
    }
  }

  @override
  Future<Comment> postComment({required CreateCommentDto commentData}) async {
    print('Attempting to post comment: $commentData');
    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');
      
      final response = await _dio.post(
        apiEndpoints.reelComment,
        data: commentData.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 201) {
        print(
          'Post comment failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to post comment: ${response.statusCode} ${response.statusMessage}',
        );
      }

      final Comment newComment = Comment.fromJson(response.data);
      print('Comment posted successfully: ${newComment.id}');
      return newComment;
    } on DioException catch (e) {
      print('Dio error posting comment: ${e.type} - ${e.message}');
      String errorMessage = 'Failed to post comment.';
      if (e.response != null) {
        errorMessage =
            'Failed to post comment: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Throwing error: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error posting comment: ${e.runtimeType} - $e');
      throw Exception('An unexpected error occurred while posting comment.');
    }
  }

  @override
  Future<void> updateComment({
    required String commentId,
    required UpdateCommentDto updateData,
  }) async {
    print('Attempting to update comment with ID: $commentId');
    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      
      final response = await _dio.patch(
        '${apiEndpoints.reelComment}/$commentId',
        data: updateData.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print(
          'Update comment failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to update comment: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Comment updated successfully: $commentId');
    } on DioException catch (e) {
      print('Dio error updating comment: ${e.type} - ${e.message}');
      String errorMessage = 'Failed to update comment.';
      if (e.response != null) {
        errorMessage =
            'Failed to update comment: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Throwing error: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error updating comment: ${e.runtimeType} - $e');
      throw Exception('An unexpected error occurred while updating comment.');
    }
  }

  @override
  Future<DeleteCommentResponseDto> deleteComment({
    required String commentId,
  }) async {
    print('Attempting to delete comment with ID: $commentId');
    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await _dio.delete(
        '${apiEndpoints.reelComment}/$commentId',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print(
          'Delete comment failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to delete comment: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print(response.data);
      print('Comment deleted successfully: $commentId');

      return DeleteCommentResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error deleting comment: ${e.type} - ${e.message}');
      String errorMessage = 'Failed to delete comment.';
      if (e.response != null) {
        errorMessage =
            'Failed to delete comment: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      print('Throwing error: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error deleting comment: ${e.runtimeType} - $e');
      throw Exception('An unexpected error occurred while deleting comment.');
    }
  }
}
