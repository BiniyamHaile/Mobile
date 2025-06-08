import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/services/api/reel_feed/reel_feed_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoFeedRepositoryImpl implements VideoFeedRepository {
  final ApiEndpoints apiEndpoints;

  VideoFeedRepositoryImpl({required this.apiEndpoints});

  final int _limitPerPage = 2;

  final String _sortBy = 'createdAt';
  final String _sortOrder = 'desc';

  @override
  Future<List<VideoItem>> fetchVideos() async {
    try {
      debugPrint(
        'Fetching initial videos: limit $_limitPerPage, sort $_sortBy $_sortOrder',
      );

      return await _fetchVideosFromApi(
        limit: _limitPerPage + 1,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );
    } catch (e) {
      debugPrint('Error fetching initial videos: $e');
      throw Exception('Failed to fetch initial videos: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoItem>> fetchMoreVideos({
    required DateTime lastVideoCreatedAt,
  }) async {
    debugPrint(
      'Fetching more videos after timestamp: ${lastVideoCreatedAt.toIso8601String()}, limit $_limitPerPage',
    );
    try {

      return await _fetchVideosAfterTimestamp(
        timestamp: lastVideoCreatedAt,
        limit: _limitPerPage,
      );
    } catch (e) {
      debugPrint('Error fetching more videos: $e');
      throw Exception('Failed to fetch more videos: ${e.toString()}');
    }
  }

  Future<List<VideoItem>> _fetchVideosFromApi({
    required int limit,
    required String sortBy,
    required String sortOrder,
  }) async {
    final url = Uri.parse(
      '${apiEndpoints.reels}/many?limit=$limit&page=1&sortBy=$sortBy&sortOrder=$sortOrder',
    );
    debugPrint('Fetching initial videos from: $url');

    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');
      
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List) {
          debugPrint('Received ${responseData.length} initial videos');
          return responseData
              .map(
                (json) => VideoItem.fromReelRto(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'API response is not a List: ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to load initial videos from API. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Exception (initial fetch): $e');
      throw Exception(
        'Network error while fetching initial videos: ${e.message}',
      );
    } on FormatException catch (e) {
      debugPrint('JSON parsing error (initial fetch): $e');
      throw Exception(
        'Invalid data format from API for initial videos: ${e.message}',
      );
    } catch (e) {
      debugPrint('Unexpected error fetching initial videos: $e');
      throw Exception(
        'An unexpected error occurred while fetching initial videos: ${e.toString()}',
      );
    }
  }

  Future<List<VideoItem>> _fetchVideosAfterTimestamp({
    required DateTime timestamp,
    required int limit,
  }) async {
    final timestampString = timestamp.toIso8601String();

    final url = Uri.parse(
      '${apiEndpoints.reels}/after?createdAt=$timestampString&limit=$limit',
    );
    debugPrint('Fetching more videos from: $url');

    try {

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List) {
          debugPrint(
            'Received ${responseData.length} more videos after ${timestamp.toIso8601String()}',
          );
          return responseData
              .map(
                (json) => VideoItem.fromReelRto(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception(
            'API response for /after is not a List: ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to load more videos from /after API. Status code: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Exception (/after fetch): $e');
      throw Exception('Network error while fetching more videos: ${e.message}');
    } on FormatException catch (e) {
      debugPrint('JSON parsing error (/after fetch): $e');
      throw Exception(
        'Invalid data format from API for more videos: ${e.message}',
      );
    } catch (e) {
      debugPrint('Unexpected error fetching more videos: $e');
      throw Exception(
        'An unexpected error occurred while fetching more videos: ${e.toString()}',
      );
    }
  }
}
