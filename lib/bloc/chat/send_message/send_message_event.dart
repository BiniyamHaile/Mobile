part of 'send_message_bloc.dart';

abstract class SendMessageEvent {}

class SendMessage extends SendMessageEvent {
  final String receiverId;
  final String text;
  final String? replyTo;
  final List<String>? filePaths;

  SendMessage({
    required this.receiverId,
    required this.text,
    this.replyTo,
    this.filePaths,
  });
}
