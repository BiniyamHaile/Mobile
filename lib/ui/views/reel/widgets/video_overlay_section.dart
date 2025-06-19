import 'package:flutter/material.dart';
import 'package:mobile/ui/views/reel/widgets/interaction_buttons.dart';
import 'package:mobile/ui/views/reel/widgets/user_info_section.dart';

class VideoOverlaySection extends StatelessWidget {
  const VideoOverlaySection({
    Key? key,
    required this.id,
    required this.profileImageUrl,
    required this.username,
    required this.description,
    required this.isBookmarked,
    required this.isLiked,
    required this.gift,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.onLikePressed,
    required this.shareLink,
    required this.onShareTap,
    required this.currentUserId,
    required this.ownerId,
     required this.onGiftStarsPressed,
  }) : super(key: key);

  final String id;
  final String profileImageUrl;
  final String username;
  final String description;
  final bool isBookmarked;
  final bool isLiked;
  final bool gift;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback onLikePressed;
  final String shareLink;
  final VoidCallback onShareTap;
  final String currentUserId;
  final String ownerId;
  final VoidCallback onGiftStarsPressed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: UserInfoSection(
              profileImageUrl: profileImageUrl,
              username: username,
              description: description,
            ),
          ),

          InteractionButtons(
            reelid: id,
            isLiked: isLiked,
            isBookmarked: isBookmarked,
            likeCount: likeCount,
            commentCount: commentCount,
            shareCount: shareCount,
            onLikePressed: onLikePressed,
            shareLink: shareLink,
            onShareTap: onShareTap,
            currentUserId: currentUserId,
            onGiftStarsPressed: onGiftStarsPressed,
            gift:gift,
            ownerId: ownerId,
          ),
        ],
      ),
    );
  }
}
