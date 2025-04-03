import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobile/models/message_model.dart';


class FavoriteChat {
  final types.User user;
  final List<ChatMessage> messages;

  FavoriteChat({required this.user, required this.messages});
}