import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool edited;
  final bool isDeleted;
  final bool isPinned;
  final List<dynamic> attachments;
  final List<String> mentionedUserIds;
  final Map<String, dynamic> reactions;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.edited,
    required this.isDeleted,
    required this.isPinned,
    required this.attachments,
    required this.mentionedUserIds,
    required this.reactions,
  });

  static ChatMessage fromJson(Map<String, dynamic> json) {

    return ChatMessage(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      edited: json['edited'] as bool,
      isDeleted: json['isDeleted'] as bool,
      isPinned: json['isPinned'] as bool,
      attachments: json['attachments'] as List<dynamic>,
      mentionedUserIds: List<String>.from(json['mentionedUserIds'] ?? []),
      reactions: Map<String, dynamic>.from(json['reactions'] ?? {}),
    );
  }

types.Message toFlutterMessage() {
  final user = types.User(id: senderId);

  if (attachments.isNotEmpty) {
    final dynamic rawAttachment = attachments.first;

    print('Raw attachment: $rawAttachment');

    if (rawAttachment is! Map<String, dynamic>) {
      return types.TextMessage(
        id: id,
        roomId: roomId,
        author: user,
        createdAt: createdAt.millisecondsSinceEpoch,
        text: '[Attachment parsing failed]',
      );
    }

    final Map<String, dynamic> attachment = rawAttachment;

    final String url = attachment['url'];
    final String mimeType = attachment['type'];
    final String type = mimeType.split('/').first;
    final String? fileName = attachment['fileName'];
    final int? size = attachment['sizeInBytes'];

    switch (type) {
      case 'image':
        return types.ImageMessage(
          id: id,
          author: user,
          createdAt: createdAt.millisecondsSinceEpoch,
          name: fileName ?? 'image.jpg',
          size: size ?? 0,
          uri: url,
        );
      case 'video':
        return types.VideoMessage(
          id: id,
          author: user,
          createdAt: createdAt.millisecondsSinceEpoch,
          name: fileName ?? 'video.mp4',
          size: size ?? 0,
          uri: url,
        );
      case 'file':
        return types.FileMessage(
          id: id,
          author: user,
          createdAt: createdAt.millisecondsSinceEpoch,
          name: fileName ?? 'file',
          size: size ?? 0,
          uri: url,
        );
      default:
        return types.TextMessage(
          id: id,
          roomId: roomId,
          author: user,
          createdAt: createdAt.millisecondsSinceEpoch,
          text: '[Unsupported attachment type: $type]',
        );
    }
  }

  return types.TextMessage(
    id: id,
    roomId: roomId,
    author: user,
    createdAt: createdAt.millisecondsSinceEpoch,
    text: content,
    metadata: {
      'edited': edited,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'reactions': reactions,
      'mentionedUserIds': mentionedUserIds,
    },
  );
}

}
