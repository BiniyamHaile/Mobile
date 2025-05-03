import 'package:flutter/material.dart';
import 'package:mobile/data/dummy_favorite.dart';
import 'package:mobile/data/dummy_recent.dart';
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
                color:Colors.grey[100],
              ),
              child: Column(
                children: <Widget>[
                  FavoriteContacts(
                    favoriteChats: favoriteChats,
                  ),
                  RecentChats(
                    recentChats: recentChats,
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
