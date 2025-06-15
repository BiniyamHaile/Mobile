
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/chat/recent_chat/recent_chat_bloc.dart';
import 'package:mobile/data/dummy_favorite.dart';
import 'package:mobile/ui/theme/app_theme.dart';
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
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor:theme.colorScheme.onPrimary ,
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary,
              ),
              child: Column(
                children: <Widget>[
                  // FavoriteContacts(
                  //   favoriteChats: favoriteChats,
                  // ),
                  Expanded(
                    child: BlocBuilder<RecentChatBloc, RecentChatState>(
                      builder: (context, state) {
                        if (state is RecentChatLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is RecentChatError) {
                          return Center(
                            child: Text(state.error),
                          );
                        } else if (state is RecentChatLoaded) {
                          final recentChats = state.recentChats;

                          if (recentChats.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.messageSquare,
                                    size: 80,
                                    color: theme.primaryColor.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No Chats Yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Start a conversation with your friends!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.primaryColor.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }

                          return RecentChats(
                            recentChats: recentChats,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
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
