


import 'package:mobile/data/dummy_user.dart';
import 'package:mobile/models/favorite_chat_model.dart';
import 'package:mobile/models/message_model.dart';

List<FavoriteChat> favoriteChats = [
  FavoriteChat(
    user: greg,
    messages: [
      ChatMessage(
        senderId: greg.id,
        receiverId: currentUser.id,
        time: '2:00 PM',
        image: ChatImage(name: 'sophia.jpg', uri: 'assets/images/sophia.jpg'),
      ),
      ChatMessage(
        senderId: greg.id,
        receiverId: currentUser.id,
        text: 'How are you?',
        time: '12:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: greg.id,
        text: 'Great!',
        time: '12:01 PM',
      ),
    ],
  ),

  FavoriteChat(
    user: james,
    messages: [
      ChatMessage(
        senderId: james.id,
        receiverId: currentUser.id,
        text: 'Hi!',
        time: '12:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: james.id,
        text: 'Hello there',
        time: '12:01 PM',
      ),
    ],
  ),

  FavoriteChat(
    user: olivia,
    messages: [
      ChatMessage(
        senderId: olivia.id,
        receiverId: currentUser.id,
        text: 'Did you see that movie?',
        time: '1:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: olivia.id,
        text: 'No, tell me about it!',
        time: '1:02 PM',
      ),
      ChatMessage(
        senderId: olivia.id,
        receiverId: currentUser.id,
        text: 'It was awesome!',
        time: '1:03 PM',
      ),
    ],
  ),
  FavoriteChat(
    user: sam,
    messages: [
      ChatMessage(
        senderId: sam.id,
        receiverId: currentUser.id,
        text: 'What are you up to this weekend?',
        time: '2:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: sam.id,
        text: 'Not sure yet, any ideas?',
        time: '2:05 PM',
      ),
    ],
  ),

  FavoriteChat(
    user: sophia,
    messages: [
      ChatMessage(
        senderId: sophia.id,
        receiverId: currentUser.id,
        text: 'Hey there!',
        time: '3:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: sophia.id,
        text: 'Hello!',
        time: '3:01 PM',
      ),
      ChatMessage(
        senderId: sophia.id,
        receiverId: currentUser.id,
        text: 'Long time no see! Checkout this [link](https://example.com)',
        time: '3:02 PM',
      ),
    ],
  ),
  FavoriteChat(
    user: steven,
    messages: [
      ChatMessage(
        senderId: steven.id,
        receiverId: currentUser.id,
        text: 'How is your project going?',
        time: '4:00 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: steven.id,
        text: 'It\'s progressing well, thanks for asking!',
        time: '4:05 PM',
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: steven.id,
        file: ChatFile(name: 'design.pdf', uri: 'assets/files/design.pdf'),
        time: '4:06 PM',
      ),
    ],
  ),
];
