part of 'recent_chat_bloc.dart';

abstract class RecentChatEvent {}

// load recent chats event

class LoadRecentChatsEvent extends RecentChatEvent {
  LoadRecentChatsEvent();
}


class UpdateRecentChatEvent extends RecentChatEvent {
  final List<RecentChat> updatedChat;

  UpdateRecentChatEvent({required this.updatedChat});
}
