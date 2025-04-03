
import 'package:mobile/data/dummy_user.dart';
import 'package:mobile/models/message_model.dart';
import 'package:mobile/models/recent_chat_model.dart';

List<RecentChat> recentChats = [
  RecentChat(
    otherUser: greg,
    messages: [
      ChatMessage(
        senderId: greg.id,
        receiverId: currentUser.id,
        text: 'Hey!',
        time: '10:00 AM',
        unread: true,
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: greg.id,
        text: 'Howdy',
        time: '10:01 AM',
        unread: true,
      ),
      ChatMessage(
        senderId: greg.id,
        receiverId: currentUser.id,
        text: 'Check out my new code [here](https://www.github.com)',
        time: '10:01 AM',
        unread: true,
      ),
      ChatMessage(
        senderId: greg.id,
        receiverId: currentUser.id,
        file: ChatFile(name: 'my_document.pdf', uri: 'path/to/my_document.pdf'),
        time: '10:02 AM',
        unread: true,
      ),
    ],
  ),
  RecentChat(
    otherUser: james,
    messages: [
      ChatMessage(
        senderId: james.id,
        receiverId: currentUser.id,
        text: 'Hey!',
        time: '10:00 AM',
        unread: false,
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: james.id,
        text: 'Howdy',
        time: '10:01 AM',
        unread: false,
      ),
    ],
  ),

  RecentChat(
    otherUser: john,
    messages: [
      ChatMessage(
        senderId: john.id,
        receiverId: currentUser.id,
        text: 'Hello! How are you?',
        time: '11:00 AM',
        unread: true,
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: john.id,
        text: 'I am good, thanks!',
        time: '11:01 AM',
        unread: true,
      ),
    ],
  ),

  RecentChat(
    otherUser: olivia,
    messages: [
      ChatMessage(
        senderId: currentUser.id,
        receiverId: olivia.id,
        text: 'Just wanted to say hi!',
        time: '12:00 PM',
        unread: true,
      ),
      ChatMessage(
        senderId: olivia.id,
        receiverId: currentUser.id,
        text: 'Hi!  Good to hear from you.',
        time: '12:05 PM',
        unread: true,
      ),
    ],
  ),
  RecentChat(
    otherUser: sam,
    messages: [
      ChatMessage(
        senderId: sam.id,
        receiverId: currentUser.id,
        text: 'Did you finish the report?',
        time: '1:00 PM',
        unread: false,
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: sam.id,
        text: 'Yes, I sent it this morning.',
        time: '1:05 PM',
        unread: false,
      ),
      ChatMessage(
        senderId: sam.id,
        receiverId: currentUser.id,
        text: 'Great, thanks!',
        time: '1:06 PM',
        unread: false,
      ),
    ],
  ),
  RecentChat(
    otherUser: sophia,
    messages: [
      ChatMessage(
        senderId: sophia.id,
        receiverId: currentUser.id,
        text: 'Reminder: Meeting at 3 PM',
        time: '2:00 PM',
        unread: true,
        image: ChatImage(name: 'sophia.jpg', uri: 'assets/images/sophia.jpg'),
      ),
    ],
  ),
  RecentChat(
    otherUser: steven,
    messages: [
      ChatMessage(
        senderId: steven.id,
        receiverId: currentUser.id,
        text: 'Need your input on the design.',
        time: '3:00 PM',
        unread: true,
      ),
      ChatMessage(
        senderId: currentUser.id,
        receiverId: steven.id,
        text: 'Okay, I will get to it',
        time: '3:15 PM',
        unread: true,
      ),
    ],
  ),
];
