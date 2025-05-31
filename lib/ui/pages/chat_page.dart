import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/chat/recent_chat/recent_chat_bloc.dart';
import 'package:mobile/data/dummy_favorite.dart';
import 'package:mobile/ui/widgets/favourite_contacts.dart';
import 'package:mobile/ui/widgets/recent_chats.dart';

class ChatPage extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (_) {
        return ChatPage();
      },
    );
  }
}

class _HomeScreenState extends State<ChatPage> {
  @override
  void initState() {
    context.read<RecentChatBloc>().add(LoadRecentChatsEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: Column(
                children: <Widget>[
                  FavoriteContacts(
                    favoriteChats: favoriteChats,
                  ),
                  BlocBuilder<RecentChatBloc, RecentChatState>(
                    builder: (context, state) {
                      if (state is RecentChatLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is RecentChatError) {
                        return Center(
                          child: Text(state.error),
                        );
                      } else if (state is RecentChatLoaded) {
                        final recentChats = state.recentChats;
                        return RecentChats(
                          recentChats: recentChats,
                        );
                        
                      }

                      return Center(
                        child: Text('No recent chats'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
