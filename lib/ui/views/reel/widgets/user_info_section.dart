import 'package:flutter/material.dart';
import 'package:mobile/ui/views/reel/widgets/description_text.dart';
import 'package:mobile/ui/views/reel/widgets/user_header.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key, required this.profileImageUrl, required this.username, required this.description});

  final String profileImageUrl;
  final String username;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            UserHeader(profileImageUrl: profileImageUrl, username: username , profileId: 'asnfmsafnksmnafk',),
            const SizedBox(height: 8),
            DescriptionText(text: description),
          ],
        ),
      ),
    );
  }
}