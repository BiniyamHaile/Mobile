import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/models/user/user_rto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }
    return userId;
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<UserRto> getUserProfile() async {
    try {
      final userId = await _getUserId();
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/auth/user/$userId',
        options: Options(headers: headers),
      );

      // print ('Userrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr  Response data: ${response.data}');
      return UserRto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<UserRto> getUserById(String id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/auth/user/$id',
        options: Options(headers: headers),
      );
      // print(
      //   'Userrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr  Response data: ${response.data}',
      // );
      return UserRto.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> followUser(String targetId) async {
    try {
      final headers = await _getAuthHeaders();
      await _dio.post(
        '${ApiEndpoints.baseUrl}/auth/follow/$targetId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser(String targetId) async {
    try {
      final headers = await _getAuthHeaders();
      await _dio.post(
        '${ApiEndpoints.baseUrl}/auth/unfollow/$targetId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  Future<bool> checkFollowStatus(String targetId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/auth/follow-status/$targetId',
        options: Options(headers: headers),
      );
      
      // Handle different response types
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is String) {
        final String status = response.data as String;
        return status.toLowerCase() == 'true';
      } else if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        if (data.containsKey('isFollowing')) {
          final value = data['isFollowing'];
          if (value is bool) return value;
          if (value is String) return value.toLowerCase() == 'true';
        }
      }
      
      return false; // Default to false if we can't determine the status
    } catch (e) {
      throw Exception('Failed to check follow status: $e');
    }
  }

  Future<List<UserRto>> getFollowers() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/auth/followers',
        options: Options(headers: headers),
      );
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> followers = response.data as List<dynamic>;
      return followers.map((user) => UserRto.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to load followers: $e');
    }
  }

  Future<List<UserRto>> getFollowing() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/auth/following',
        options: Options(headers: headers),
      );
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> following = response.data as List<dynamic>;
      return following.map((user) => UserRto.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to load following: $e');
    }
  }

  Future<List<VideoItem>> getUserVideos() async {
    try {
      final userId = await _getUserId();
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/reel/user/$userId',
        options: Options(headers: headers),
      );
      
      if (response.data == null) {
        return [];
      }

      final List<dynamic> reels = response.data as List<dynamic>;
      return reels.map((reel) => VideoItem.fromReelRto(reel)).toList();
    } catch (e) {
      throw Exception('Failed to load user videos: $e');
    }
  }
} 