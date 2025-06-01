import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:mobile/models/chat/recent_chat.dart';
import 'package:mobile/models/message_model.dart';
import 'package:mobile/ui/pages/chat_screen.dart';
import 'package:intl/intl.dart';

class RecentChats extends StatelessWidget {
  final List<RecentChat> recentChats;

  const RecentChats({Key? key, required this.recentChats}) : super(key: key);

String formatChatTimestamp(String isoDate) {
  final date = DateTime.parse(isoDate);
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(date.year, date.month, date.day);

  final isToday = today == messageDay;
  final isSameYear = now.year == date.year;

  if (isToday) {
    return DateFormat('hh:mm a').format(date); // → 10:30 AM
  }

  final daysDifference = now.difference(messageDay).inDays;

  if (daysDifference < 7 && now.weekday >= date.weekday) {
    return DateFormat('EEE').format(date); // → Mon, Tue
  }

  if (now.month == date.month && now.year == date.year) {
    return DateFormat('MMM d').format(date); // → May 12
  }

  if (isSameYear) {
    return DateFormat('MMM d').format(date); // → Feb 5
  }

  return DateFormat('MM/dd/yyyy').format(date); // → 11/24/2023
}


  @override
  Widget build(BuildContext context) {
  
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                child: ListView.builder(
                  itemCount: recentChats.length,
                  itemBuilder: (BuildContext context, int index) {
                    final RecentChat recentChat = recentChats[index];
                    final types.User otherUser = new types.User(
                      id: recentChat.user.id,
                      firstName: recentChat.user.firstName,
                      imageUrl: recentChat.user.profilePic,
                    );

                    final currentUserId = recentChat.participants
                        .firstWhere((id) => id != recentChat.user.id);

                    final isLastMessageMine =
                        recentChat.lastMessageSenderId == currentUserId;

                    final receiverId = isLastMessageMine
                        ? recentChat.user.id
                        : currentUserId;


                    final ChatMessage lastMessage = ChatMessage(
                        senderId: recentChat.lastMessageSenderId!,
                        receiverId: receiverId,
                        text: recentChat.lastMessageContent,
                        time: recentChat.lastMessageTime?.toIso8601String(),
                        unread: recentChat.unreadCount > 0,
                      );

                    final types.User currentUser = types.User(
                      id: currentUserId,
                      firstName: recentChat.currentUser.firstName,
                      imageUrl: recentChat.currentUser.profilePic,
                    );

                    return GestureDetector(
                      onTap: ()=> Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            user: currentUser,
                            friend: otherUser,
                            roomId: recentChat.roomId,
                          ),
                        ),
                      ),

                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 5.0, bottom: 5.0, right: 10.0, left: 10.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: lastMessage.unread
                              ? const Color.fromARGB(255, 230, 227, 227)
                              : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                            bottomLeft: Radius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          // Removed mainAxisAlignment to allow flexible width distribution
                          children: <Widget>[
                            Expanded( // Wrap the left side in Expanded
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 35.0,
                                    backgroundImage: otherUser.imageUrl != null?  CachedNetworkImageProvider(
                                      otherUser.imageUrl ?? '',
                                    ) : AssetImage(
                                      'assets/images/user.png',
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded( // Wrap the column with text in Expanded
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          otherUser.firstName ?? 'Unknown User',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          lastMessage.text ?? 'No messages yet',
                                          style: const TextStyle(
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
                            const SizedBox(width: 8.0), // Add a small spacing between the two sections
                            Column(
                              children: <Widget>[
                                Text(
                                  formatChatTimestamp(lastMessage.time!),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                lastMessage.unread && !isLastMessageMine
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
                                          '${recentChat.unreadCount} NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : recentChat.unreadCount > 0 && isLastMessageMine ? Icon(
                                        Icons.done
                                    ) :  recentChat.unreadCount > 0 && isLastMessageMine ? Icon(
                                        Icons.done_all
                                    ) : const SizedBox.shrink(),
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