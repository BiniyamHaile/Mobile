import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/like_reel_response_dto.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/reel.dart';
import 'package:mobile/models/reel/report/create_report_dto.dart';
import 'package:mobile/models/reel/share_reel_response_dto.dart';
import 'package:mobile/models/reel/update_reel.dart';
import 'package:mobile/services/api/reel/reel_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelRepositoryImpl implements ReelRepository {
  final Dio _dio;
  final ApiEndpoints apiEndpoints;

  ReelRepositoryImpl({Dio? dio, required this.apiEndpoints})
      : _dio = dio ?? Dio();

  String _privacyOptionToBackendString(PrivacyOption option) {
    switch (option) {
      case PrivacyOption.public:
        return 'public';
      case PrivacyOption.followers:
        return 'followers';
      case PrivacyOption.friends:
        return 'friends';
      case PrivacyOption.onlyYou:
        return 'only_me';
    }
  }

  @override
  Future<void> postReel({
    required String videoFilePath,
    required CreateReelDto reelData,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'videoFile': await MultipartFile.fromFile(
          videoFilePath,
          filename: videoFilePath.split('/').last,
        ),
        'description': reelData.description,
        'duration': reelData.duration,
        'isPremiumContent': reelData.isPremiumContent,
        'privacy': reelData.privacy != null
            ? _privacyOptionToBackendString(reelData.privacy!)
            : null,
        'allowComments': reelData.allowComments,
        'allowSaveToDevice': reelData.allowSaveToDevice,
        'saveWithWatermark': reelData.saveWithWatermark,
        'audienceControlUnder18': reelData.audienceControlUnder18,
        'mentionedUsers':
            reelData.mentionedUsers?.map((u) => u.toJson()).toList(),
      });

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await _dio.post(
        apiEndpoints.reels,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 201) {
        throw Exception(
          'Failed to post reel: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Reel posted successfully!');
    } on DioException catch (e) {
      print('Dio error posting reel: ${e.message}');
      String errorMessage = 'Failed to post reel.';
      if (e.response != null) {
        errorMessage =
            'Failed to post reel: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error posting reel: $e');
      throw Exception('An unexpected error occurred while posting reel.');
    }
  }

  @override
  Future<void> updateReel({
    required String reelId,
    required UpdateReelDto updateData,
  }) async {
    try {
      print(
          "Attempting to update reel: $reelId at ${'${apiEndpoints.reels}/$reelId'}");

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');
      final response = await _dio.patch(
        '${apiEndpoints.reels}/$reelId',
        data: updateData.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update reel: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Reel updated successfully!');
    } on DioException catch (e) {
      print('Dio error updating reel: ${e.message}');
      String errorMessage = 'Failed to update reel.';
      if (e.response != null) {
        errorMessage =
            'Failed to update reel: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
        if (e.response?.statusCode == 404) {
          errorMessage = 'Reel not found for update.';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error updating reel: $e');
      throw Exception('An unexpected error occurred while updating reel.');
    }
  }

  @override
  Future<void> deleteReel({required String reelId}) async {
    try {
      print(
          "Attempting to delete reel: $reelId at ${'${apiEndpoints.reels}/$reelId'}");

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await _dio.delete(
        '${apiEndpoints.reels}/$reelId',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete reel: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Reel deleted successfully: $reelId');
    } on DioException catch (e) {
      print('Dio error deleting reel: ${e.message}');
      String errorMessage = 'Failed to delete reel.';
      if (e.response != null) {
        errorMessage =
            'Failed to delete reel: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
        if (e.response?.statusCode == 404) {
          errorMessage = 'Reel not found for deletion.';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error deleting reel: $e');
      throw Exception('An unexpected error occurred while deleting reel.');
    }
  }

  @override
  Future<LikeReelResponseDto> like({required CreateLikeDto likeData}) async {
    try {
      print(
        "Attempting to like/unlike reel: ${likeData.targetId} by user: ${likeData.userId}",
      );

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await _dio.post(
        apiEndpoints.likeReel,
        data: likeData.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to like/unlike reel: Unexpected status code ${response.statusCode} ${response.statusMessage}',
        );
      }

      print(
        'Reel Like/Unlike operation successful for reel ID: ${likeData.targetId}',
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid response data format for like/unlike operation.',
        );
      }

      return LikeReelResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error liking/unliking reel: ${e.message}');
      String errorMessage = 'Failed to like/unlike reel.';
      if (e.response != null) {
        errorMessage =
            'Failed to like/unlike reel: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }

        if (e.response?.statusCode == 404) {
          errorMessage = 'Like target (Reel) or User not found.';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error liking/unliking reel: $e');
      throw Exception(
        'An unexpected error occurred while liking/unliking reel.',
      );
    }
  }

  @override
  Future<ShareReelResponseDto> shareReel({required String reelId}) async {
    try {
      print(
        "Attempting to share reel: $reelId at ${'${apiEndpoints.shareReel}/$reelId'}",
      );

      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');

      final response = await _dio.post(
        '${apiEndpoints.shareReel}/$reelId',
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          'Share reel failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to share reel: Unexpected status code ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Reel shared successfully: $reelId');

      return ShareReelResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error sharing reel: ${e.type} - ${e.message}');
      String errorMessage = 'Failed to share reel.';
      if (e.response != null) {
        errorMessage =
            'Failed to share reel: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }

        if (e.response?.statusCode == 404) {
          errorMessage = 'Reel not found for sharing.';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error sharing reel: ${e.runtimeType} - $e');
      throw Exception('An unexpected error occurred while sharing reel.');
    }
  }

  @override
  Future<void> reportReel({required CreateReportDto reportData}) async {
    print(
      "Attempting to report entity: ${reportData.reportedEntityId} of type ${reportData.reportedEntityType.value} with reason: ${reportData.reasonDetails.mainReason}",
    );

    final prefs = await SharedPreferences.getInstance();
    var authToken = prefs.getString('token');

    try {
      final response = await _dio.post(
        apiEndpoints.reportReel,
        data: reportData.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $authToken'},
        ),
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        print(
          'Report entity failed with status: ${response.statusCode}. Response data: ${response.data}',
        );
        throw Exception(
          'Failed to report entity: Unexpected status code ${response.statusCode} ${response.statusMessage}',
        );
      }

      print(
        'Entity reported successfully: ${reportData.reportedEntityId} (${reportData.reportedEntityType.value})',
      );

    } on DioException catch (e) {
      print('Dio error reporting entity: ${e.type} - ${e.message}');
      String errorMessage = 'Failed to report entity.';
      if (e.response != null) {
        errorMessage =
            'Failed to report entity: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
        if (e.response?.statusCode == 400) {
          errorMessage =
              'Invalid report data.';
          if (e.response?.data != null &&
              e.response!.data is Map &&
              e.response!.data['message'] != null) {
            errorMessage += ' Backend message: ${e.response!.data['message']}';
          }
        } else if (e.response?.statusCode == 404) {
          errorMessage =
              'Reported entity not found.';
          if (e.response?.data != null &&
              e.response!.data is Map &&
              e.response!.data['message'] != null) {
            errorMessage += ' Backend message: ${e.response!.data['message']}';
          }
        } else if (e.response?.statusCode == 409) {
          errorMessage =
              'Entity already reported.';
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
      print('Unknown error reporting entity: ${e.runtimeType} - $e');
      throw Exception('An unexpected error occurred while reporting entity.');
    }
  }
}
