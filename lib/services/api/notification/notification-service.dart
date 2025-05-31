import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:mobile/services/api/global/base_repository.dart';

class NotificationApiService extends BaseRepository{

 Future<List<NotificationModel>> retrieveNotifications() async{

      final response = await get(ApiEndpoints().notifications, 
      headers: {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ODI4YWI3MzAzNmZjNTY1Y2Y5YWI2MzYiLCJlbWFpbCI6ImRvdWRkZW1tYW1hdXR0ZS01ODAwQHlvcG1haWwuY29tIiwicm9sZSI6InVzZXIiLCJpYXQiOjE3NDc1ODQzNTAsImV4cCI6MTc0NzU4Nzk1MH0.l5WdB8Xlpx1ECfBw6zF4xxCt8mqS2ZTXnoiHb9z5oQA',
      }
      );
    if (response.statusCode == 200) {
      final List<NotificationModel> notifications = 
    (response.data as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();

      return notifications;
    } else {
      throw Exception('Failed to load notifications');

    }
 }
}