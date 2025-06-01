import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/core/injections/get_it.dart';
import 'package:mobile/models/chat/recent_chat.dart';
import 'package:mobile/services/api/chat/chat-service.dart';
import 'package:mobile/services/socket/websocket-service.dart';

part 'recent_chat_event.dart';
part 'recent_chat_state.dart';

class RecentChatBloc extends Bloc<RecentChatEvent, RecentChatState> {
  RecentChatBloc() : super(RecentChatInitial()) {
    on<LoadRecentChatsEvent>(_loadRecentChats);
    on<UpdateRecentChatEvent>(_updateRecentChat);

    // Listen to socket stream and dispatch event on new updates
    getIt<WebSocketService>().recentChatUpdateStream.listen((chat) {
      add(UpdateRecentChatEvent(updatedChat: chat));
    });
  }

  Future<void> _loadRecentChats(
      LoadRecentChatsEvent event, Emitter<RecentChatState> emit) async {
    final recentChatService = ChatApiService();

    emit(RecentChatLoading());

    try {
      final recentChats = await recentChatService.retrieveRecentChats();
      emit(RecentChatLoaded(recentChats));
    } catch (e) {
      emit(RecentChatError(e.toString()));
    }
  }

  void _updateRecentChat(
      UpdateRecentChatEvent event, Emitter<RecentChatState> emit) {
    emit(RecentChatLoaded(event.updatedChat));
  }
}
