import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String? text;
  final String? time;
  final ChatFile? file;
  final ChatImage? image;
  final bool unread;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    this.text,
    this.time,
    this.file,
    this.image,
    this.unread = true,
  });
}

class ChatFile {
  final String uri;
  final String name;

  ChatFile({required this.uri, required this.name});
}

class ChatImage {
  final String uri;
  final String name;

  ChatImage({required this.uri, required this.name});
}

