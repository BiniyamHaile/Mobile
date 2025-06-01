import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/chat/chat_messages.dart';
import 'package:mobile/services/api/chat/chat-service.dart';

part 'send_message_event.dart';
part 'send_message_state.dart';

class SendMessageBloc extends Bloc<SendMessageEvent, SendMessageState> {
  SendMessageBloc() : super(SendMessageInitial()) {
    on<SendMessageEvent>((event, emit) { });
    on<SendMessage>(_handleSendMessage);
  }

  Future<void> _handleSendMessage(
    SendMessage event,
    Emitter<SendMessageState> emit,
  ) async {
    emit(SendMessageLoading());

    final chatService = ChatApiService();

    try {
    final ChatMessage message = await chatService.sendMessage(
  event.receiverId,
  event.text,
  event.replyTo,
  filePaths: event.filePaths,
);

      emit(SendMessageSuccess(message: message));
    } catch (error) {
      print("error during send message: $error");
      emit(SendMessageFailure(error: error.toString()));
    }
  }
  
}
