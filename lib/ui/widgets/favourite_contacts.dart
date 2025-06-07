import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobile/data/dummy_user.dart';
import 'package:mobile/models/favorite_chat_model.dart';
import 'package:mobile/ui/pages/chat_screen.dart';


class FavoriteContacts extends StatelessWidget {
  final List<FavoriteChat> favoriteChats;

  const FavoriteContacts({Key? key, required this.favoriteChats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Favorite Contacts',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
               
              ],
            ),
          ),
          Container(
            height: 120.0,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 10.0),
              scrollDirection: Axis.horizontal,
              itemCount: favoriteChats.length,
              itemBuilder: (BuildContext context, int index) {
                final FavoriteChat favoriteChat = favoriteChats[index];
                final types.User favoriteUser = favoriteChat.user;

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        user: currentUser,
                        friend: favoriteUser,
                        roomId: "",
                        // initialMessages: favoriteChat.messages,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35.0,
                          backgroundImage: AssetImage(
                            favoriteUser.imageUrl ?? 'assets/images/default_profile.png',
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          favoriteUser.firstName ?? 'Unknown User',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
