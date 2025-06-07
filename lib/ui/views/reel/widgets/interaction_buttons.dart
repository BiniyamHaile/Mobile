import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/ui/styles/app_colors.dart';
import 'package:mobile/ui/views/reel/report/share_bottom_sheet.dart';
import 'package:mobile/ui/views/reel/widgets/comment_section.dart';
import 'package:mobile/ui/views/reel/widgets/interaction_button.dart';

class InteractionButtons extends StatelessWidget {
  final String reelid;
  final bool isLiked;
  final bool isBookmarked;
  final bool gift;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback onLikePressed;
  final String shareLink;
  final VoidCallback onShareTap;
  final String currentUserId;
  final VoidCallback onGiftStarsPressed;

  final appColors = AppColors();

  InteractionButtons({
    super.key,
    required this.reelid,
    required this.isLiked,
    required this.isBookmarked,
    required this.gift,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.onLikePressed,
    required this.shareLink,
    required this.onShareTap,
    required this.currentUserId,
    required this.onGiftStarsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 20,
        children: [
          InteractionButton(
            id: reelid,
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: likeCount,
            color: isLiked ? appColors.redColor : appColors.whiteColor,
            onTap: onLikePressed,
          ),
          if (gift)
            InteractionButton(
              id: reelid,
              icon: LucideIcons.star,
              count: -1,
              color: appColors.whiteColor,
              onTap: onGiftStarsPressed,
            ),
          InteractionButton(
            id: reelid,
            icon: LucideIcons.messageCircle,
            count: commentCount,
            color: appColors.whiteColor,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return CommentSection(
                    currentUserId: currentUserId,
                    reelId: reelid,
                    commentCount: commentCount,
                    onClose: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
          // Share Button
          InteractionButton(
            id: reelid,
            icon: LucideIcons.send,
            count: shareCount,
            color: appColors.whiteColor,
            onTap: onShareTap,
            shareLink: shareLink,
          ),
          InteractionButton(
            id: reelid,
            icon: LucideIcons.send,
            count: shareCount,
            color: appColors.whiteColor,
            onTap: onShareTap,
            shareLink: shareLink,
          ),
          InteractionButton(
            id: reelid,
            icon: LucideIcons.menu,
            count: -1,
            color: appColors.whiteColor,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return ShareBottomSheet(reelid: reelid);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
