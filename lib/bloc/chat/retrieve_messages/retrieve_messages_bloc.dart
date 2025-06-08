import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/chat/chat_messages.dart';
import 'package:mobile/services/api/chat/chat-service.dart';

part 'retrieve_messages_event.dart';
part 'retrieve_messages_state.dart';

class RetrieveMessagesBloc extends Bloc<RetrieveMessagesEvent, RetrieveMessagesState> {
  RetrieveMessagesBloc() : super(RetrieveMessagesInitial()) {
    on<RetrieveMessagesEvent>((event, emit) {});
    on<RetrieveMessages>(_handleRetrieveMessages);
    on<AddMessageToQueue>(_handleAddMessageToQueue);
  }

  Future<void> _handleRetrieveMessages(
    RetrieveMessages event,
    Emitter<RetrieveMessagesState> emit,
  ) async {
    emit(RetrieveMessagesLoading());

    final chatService = ChatApiService();

    try {
      final List<ChatMessage> messages = await chatService.retrieveMessages(event.roomId);
      emit(RetrieveMessagesSuccess(messages: messages));
    } catch (error) {
      emit(RetrieveMessagesFailure(error: error.toString()));
    }
  }

  void _handleAddMessageToQueue(
    AddMessageToQueue event,
    Emitter<RetrieveMessagesState> emit,
  ) {
    if (state is RetrieveMessagesSuccess) {
      final currentState = state as RetrieveMessagesSuccess;
      // add the new message to fist index
      final updatedMessages = List<ChatMessage>.from(currentState.messages);
      updatedMessages.insert(0, event.message);
      emit(RetrieveMessagesSuccess(messages: updatedMessages));
    } else {
      emit(RetrieveMessagesSuccess(messages: [event.message]));
    }
  }
}
