part of 'recent_chat_bloc.dart';

@immutable
sealed class RecentChatState {}

final class RecentChatInitial extends RecentChatState {}

final class RecentChatLoading extends RecentChatState {}

final class RecentChatLoaded extends RecentChatState {
  final List<RecentChat> recentChats;

  RecentChatLoaded(this.recentChats);
}

final class RecentChatError extends RecentChatState {
  final String error;

  RecentChatError(this.error);
}