import 'package:mobile/models/profile.dart';


class RecentChat {
  final String roomId;
  final int unreadCount;
  final DateTime updatedAt;
  final List<String> participants;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Profile user;
  final Profile currentUser;

  RecentChat({
    required this.roomId,
    required this.unreadCount,
    required this.updatedAt,
    required this.participants,
    required this.user,
    required this.currentUser,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageTime,
  });

  factory RecentChat.fromJson(Map<String, dynamic> json) {
    final chat = json['chat'];
    final lastMessage = chat['lastMessage'];

    return RecentChat(
      roomId: chat['roomId'] as String,
      unreadCount: chat['unreadCount'] as int,
      updatedAt: DateTime.parse(chat['updatedAt'] as String),
      participants: List<String>.from(chat['participants'] as List),
      lastMessageContent: lastMessage?['content'],
      lastMessageSenderId: lastMessage?['senderId'],
      lastMessageTime: lastMessage?['sentAt'] != null
          ? DateTime.parse(lastMessage['sentAt'])
          : null,
      user: Profile.fromJson(json['user']),
      currentUser: Profile.fromJson(json['currentUser']),
    );
  }
}
