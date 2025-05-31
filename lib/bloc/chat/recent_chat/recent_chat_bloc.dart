import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mobile/models/chat/recent_chat.dart';
import 'package:mobile/services/api/chat/chat-service.dart';

part 'recent_chat_event.dart';
part 'recent_chat_state.dart';

class RecentChatBloc extends Bloc<RecentChatEvent, RecentChatState> {
  RecentChatBloc() : super(RecentChatInitial()) {
    on<RecentChatEvent>((event, emit) {});
    on<LoadRecentChatsEvent>((event, emit) => loadRecentChats(event, emit));
  }

  Future<void> loadRecentChats(LoadRecentChatsEvent event, Emitter<RecentChatState> emit ) async {
    final recentChatService = ChatApiService();

    emit(RecentChatLoading());

    try {
      final recentChats = await recentChatService.retrieveRecentChats();
      emit(RecentChatLoaded(recentChats));
    } catch (e) {
      emit(RecentChatError(e.toString()));
    }
  }
}
