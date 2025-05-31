part of 'retrieve_messages_bloc.dart';

abstract class RetrieveMessagesEvent {}

class RetrieveMessages extends RetrieveMessagesEvent {
  final String roomId;

  RetrieveMessages({
    required this.roomId,
  });
}


class AddMessageToQueue extends RetrieveMessagesEvent {
  final ChatMessage message;

  AddMessageToQueue({
    required this.message,
  });
}