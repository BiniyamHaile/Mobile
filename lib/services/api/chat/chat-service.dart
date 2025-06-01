import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/models/chat/recent_chat.dart';
import 'package:mobile/services/api/global/base_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/chat/chat_messages.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatApiService extends BaseRepository {
  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? "";
  }

  Future<List<RecentChat>> retrieveRecentChats() async {
    final token = await getAccessToken();
    final response = await get(ApiEndpoints().recentChats, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<RecentChat> recentChats = (response.data as List)
          .map((item) => RecentChat.fromJson(item))
          .toList();

      return recentChats;
    } else {
      throw Exception('Failed to load recent chats');
    }
  }

  Future<List<ChatMessage>> retrieveMessages(String roomId) async {
    final token = await getAccessToken();
    final response =
        await get(ApiEndpoints().retrieveMessages(roomId), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<ChatMessage> recentChats = (response.data as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList();

      return recentChats;
    } else {
      throw Exception('Failed to load recent chats');
    }
  }

  Future<ChatMessage> sendMessage(
    String receiverId,
    String text,
    String? replyTo, {
    List<String>? filePaths,
  }) async {
    final token = await getAccessToken();
    final formData = FormData.fromMap({
      'content': text,
      'receiverId': receiverId,
      if (replyTo != null) 'replyTo': replyTo,
      if (filePaths != null && filePaths.isNotEmpty)
        'files': [
          for (final path in filePaths)
            await MultipartFile.fromFile(
              path,
              filename: path.split('/').last,
              contentType: MediaType.parse(
                lookupMimeType(path) ?? 'application/octet-stream',
              ),
            )
        ]
    });

    final response = await dio.post(
      ApiEndpoints().sendMessage,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 201) {
      print("response data: ${response.data}");
      return ChatMessage.fromJson(response.data);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
