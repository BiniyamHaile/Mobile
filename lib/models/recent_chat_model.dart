import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobile/models/message_model.dart';


class RecentChat {
  final types.User otherUser;
  final List<ChatMessage> messages;

  RecentChat({required this.otherUser, required this.messages});
}