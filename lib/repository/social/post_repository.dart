import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/services/api/global/base_repository.dart';

class PostRepository extends BaseRepository {
  Future<FindResult<Post>> fetchPosts({
    int? limit,
    int? offset,
    String? next,
    String? previous,
  }) async {
    print(
        'Fetching posts with limit: $limit, offset: $offset, next: $next, previous: $previous');
    try {
      final response = await get(
        '/social/posts',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
          if (next != null) 'next': next,
          if (previous != null) 'previous': previous,
        },
      );

      print('Response>>>: $response');

      return FindResult.fromJson(
        response.data,
        (json) => Post.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception('Failed to load posts: ${e.message}');
    }
  }

  Future<Post> updatePost({
    required String postId,
    String? content,
    List<File>? files,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (content != null) 'content': content,
        if (files != null)
          'files': await Future.wait(
            files.map((file) async => await MultipartFile.fromFile(file.path)),
          ),
      });

      print('Updating post with formData: $formData');
      final response = await dio.patch(
        '/social/posts/$postId',
        data: formData,
      );

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update post: ${e.message}');
    }
  }

  // Add this to your existing PostRepository
  Future<Post> createPost({
    String? content,
    List<File>? files,
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (files != null)
          'files': await Future.wait(
            files.map((file) async => await MultipartFile.fromFile(file.path)),
          ),
      });

      final response = await dio.post(
        '/social/posts',
        data: formData,
      );

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create post: ${e.message}');
    }
  }

  Future<Post> reportPost({
    String? postId,
    String? mainReason,
    String? subReason,
    String? reportType,
  }) async {
    try {
      final formData = FormData.fromMap({
        "reportType": "post",
        'mainReason': mainReason,
        'subReason': subReason,
      });

      final response = await dio.post(
        '/social/posts/$postId/report',
        data: formData,
      );

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create post: ${e.message}');
    }
  }

  Future<void> deletePost({required String postId}) async {
    try {
      await dio.delete('/social/posts/$postId');
    } on DioException catch (e) {
      throw Exception('Failed to delete post: ${e.message}');
    }
  }
}
