import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/services/api/global/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences: $prefs');
      var token = prefs.getString('token');
      print('Token>>: $token');
      final response = await get(
        '/social/posts',
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
          if (next != null) 'next': next,
          if (previous != null) 'previous': previous,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
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
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences: $prefs');
      var token = prefs.getString('token');
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
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
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
    List<String>? mentions,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');


      final formData = FormData.fromMap({
        'content': content,
        if (files != null)
          'files': await Future.wait(
            files.map((file) async => await MultipartFile.fromFile(file.path)),
          ),
        "mentions": mentions,
      });

      final response = await dio.post(
        '/social/posts',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create post: ${e.message}');
    }
  }


  Future<void> deletePost({required String postId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences: $prefs');
      var token = prefs.getString('token');
      print('Token>>: $token');
      await dio.delete(
        '/social/posts/$postId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } on DioException catch (e) {
      throw Exception('Failed to delete post: ${e.message}');
    }
  }

  Future<Post> toggleReaction({
    required String postId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('SharedPreferences: $prefs');
      var token = prefs.getString('token');
      print('Token>>: $token');

      final response = await dio.post(
        '/social/posts/$postId/toggleReaction',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data'
        }),
      );

      return Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to toggle reaction: ${e.message}');
    }
  }
}
