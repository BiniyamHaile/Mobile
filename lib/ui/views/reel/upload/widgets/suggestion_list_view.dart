import 'package:flutter/material.dart';
import 'package:mobile/models/reel/hashtag_suggestion.dart';
import 'package:mobile/models/reel/user_suggestion.dart';

class SuggestionListView extends StatelessWidget {
  final List<HashtagSuggestion> hashtags;
  final List<UserSuggestion> users;
  final String activeType; 
  final ValueChanged<String> onSuggestionSelected;

  const SuggestionListView({
    Key? key,
    required this.hashtags,
    required this.users,
    required this.activeType,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? listContent;
    int itemCount = 0;

    if (activeType == '#') {
      itemCount = hashtags.length;
      if (itemCount > 0) {
        listContent = ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final suggestion = hashtags[index];
            return ListTile(
              title: Text(
                '#${suggestion.hashtag}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(suggestion.postCount),
              onTap: () {
                onSuggestionSelected('#${suggestion.hashtag} ');
              },
            );
          },
        );
      } else {
        listContent = const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hashtags found.', style: TextStyle(color: Colors.grey)),
        );
      }
    } else if (activeType == '@') {
      itemCount = users.length;
      if (itemCount > 0) {
        listContent = ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.imageUrl),
                radius: 20,
              ),
              title: Text(user.name),
              subtitle: Text('@${user.username}'),
              onTap: () {
                onSuggestionSelected('@${user.username} ');
              },
            );
          },
        );
      } else {
        listContent = const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No users found.', style: TextStyle(color: Colors.grey)),
        );
      }
    }

    if (listContent == null) {
      return const SizedBox.shrink();
    }

    return listContent;
  }
}