import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobile/data/dummy_user.dart';
import 'package:mobile/models/message_model.dart';
import 'package:mobile/models/recent_chat_model.dart';
import 'package:mobile/ui/pages/chat_screen.dart';

class RecentChats extends StatelessWidget {
  final List<RecentChat> recentChats;

  const RecentChats({Key? key, required this.recentChats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
            child: Text(
              'Recent Chats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: ListView.builder(
                  itemCount: recentChats.length,
                  itemBuilder: (BuildContext context, int index) {
                    final RecentChat recentChat = recentChats[index];
                    final types.User otherUser = recentChat.otherUser;
                    final ChatMessage lastMessage =
                        recentChat.messages.isNotEmpty
                            ? recentChat.messages.last
                            : ChatMessage(
                                senderId: currentUser.id,
                                receiverId: greg.id,
                                text: "No Message",
                                time: "0:00");

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            user: currentUser,
                            friend: otherUser,
                            initialMessages: recentChat.messages,
                          ),
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(
                            top: 5.0, bottom: 5.0, right: 10.0, left: 10.0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: lastMessage.unread
                              ? Color.fromARGB(255, 230, 227, 227)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          // Removed mainAxisAlignment to allow flexible width distribution
                          children: <Widget>[
                            Expanded(
                              // Wrap the left side in Expanded
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 35.0,
                                    backgroundImage: AssetImage(otherUser
                                            .imageUrl ??
                                        'assets/images/default_profile.png'),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    // Wrap the column with text in Expanded
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          otherUser.firstName ?? 'Unknown User',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          lastMessage.text ?? 'No messages yet',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    8.0), // Add a small spacing between the two sections
                            Column(
                              children: <Widget>[
                                Text(
                                  lastMessage.time ?? '',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                lastMessage.unread
                                    ? Container(
                                        width: 40.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
