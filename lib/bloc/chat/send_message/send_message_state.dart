part of 'send_message_bloc.dart';

@immutable
sealed class SendMessageState {}

final class SendMessageInitial extends SendMessageState {}


final class SendMessageLoading extends SendMessageState {}

final class SendMessageSuccess extends SendMessageState {
  final ChatMessage message;

  SendMessageSuccess({required this.message});
}

final class SendMessageFailure extends SendMessageState {
  final String error;

  SendMessageFailure({required this.error});
}

