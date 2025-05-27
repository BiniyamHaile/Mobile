import 'package:flutter/material.dart';
import 'package:mobile/models/reel/privacy_option.dart';

String _getPrivacyText(PrivacyOption option) {
  switch (option) {
    case PrivacyOption.public:
      return 'public';
    case PrivacyOption.followers:
      return 'Followers';
    case PrivacyOption.friends:
      return 'Friends';
    case PrivacyOption.onlyYou:
      return 'Only you';
  }
}

class PostOptionsSection extends StatelessWidget {
  final PrivacyOption selectedPrivacy;
  final VoidCallback onPrivacyTap;
  final VoidCallback onMoreOptionsTap;

  const PostOptionsSection({
    Key? key,
    required this.selectedPrivacy,
    required this.onPrivacyTap,
    required this.onMoreOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outline, color: Colors.redAccent),
          title: Text('${_getPrivacyText(selectedPrivacy)} can view this post'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPrivacyTap, 
        ),
        ListTile(
          leading: const Icon(Icons.more_horiz),
          title: const Text('More options'),
          subtitle: const Text('Manage upload quality'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onMoreOptionsTap,
        ),
      ],
    );
  }
}
