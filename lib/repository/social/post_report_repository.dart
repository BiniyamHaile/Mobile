import 'package:dio/dio.dart';
import 'package:mobile/models/report_post.dart';
import 'package:mobile/services/api/global/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostReportRepository extends BaseRepository {
  Future<void> createReport(PostReport report) async {
    print('Creating post report with data: ${report.toJson()}');
    final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
    try {
      await dio.post(
        '/social/posts/${report.content_id}/report',
        data: {
          'mainReason': report.mainReason,
          'subreason': report.subreason,
          'reportType': report.reportType,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
    } catch (e) {
      print('Error creating post report: $e');
      throw Exception('Failed to create post report: $e');
    }
  }
}
