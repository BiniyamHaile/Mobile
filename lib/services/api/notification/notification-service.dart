import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:mobile/services/api/global/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationApiService extends BaseRepository {
  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }

  Future<List<NotificationModel>> retrieveNotifications() async {
    final token = await getAccessToken();
    final response = await get(ApiEndpoints().notifications, headers: {
      'Authorization':
          'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<NotificationModel> notifications = (response.data as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList();

      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
