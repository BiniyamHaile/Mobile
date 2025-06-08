part of 'retrieve_messages_bloc.dart';

@immutable
sealed class RetrieveMessagesState {}

final class RetrieveMessagesInitial extends RetrieveMessagesState {}

final class RetrieveMessagesLoading extends RetrieveMessagesState {}

final class RetrieveMessagesSuccess extends RetrieveMessagesState {
  final List<ChatMessage> messages;

  RetrieveMessagesSuccess({
    required this.messages,
  });
}

final class RetrieveMessagesFailure extends RetrieveMessagesState {
  final String error;

  RetrieveMessagesFailure({
    required this.error,
  });
}