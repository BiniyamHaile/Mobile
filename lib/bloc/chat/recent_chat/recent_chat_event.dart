part of 'recent_chat_bloc.dart';

abstract class RecentChatEvent {}

// load recent chats event

class LoadRecentChatsEvent extends RecentChatEvent {
  LoadRecentChatsEvent();
}