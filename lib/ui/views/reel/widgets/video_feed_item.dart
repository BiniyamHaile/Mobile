// mobile/ui/views/reel/widgets/video_feed_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/likeable_type.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/views/reel/widgets/optimized_video_player.dart';
import 'package:mobile/ui/views/reel/widgets/video_overlay_section.dart';
import 'package:video_player/video_player.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({
    super.key,
    required this.videoItem,
    required this.currentUserId,
    required this.controller,
  });

  final VideoItem videoItem;
  final String currentUserId;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OptimizedVideoPlayer(controller: controller, videoId: videoItem.id),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<ReelFeedAndActionBloc, ReelFeedAndActionState>(
            builder: (context, state) {
              final isLiked = state.likedVideoIds.contains(videoItem.id);
              return VideoOverlaySection(
                  id: videoItem.id,
                  profileImageUrl: videoItem.profileImageUrl,
                  username: videoItem.username,
                  description: videoItem.description,
                  isBookmarked: videoItem.isBookmarked,
                  isLiked: isLiked,
                  likeCount: videoItem.likeCount,
                  commentCount: videoItem.commentCount,
                  shareCount: videoItem.shareCount,
                  onLikePressed: () {
                    final likeData = CreateLikeDto(
                        userId: currentUserId,
                        targetId: videoItem.id,
                        onModel: LikeableType.reel);
                    context
                        .read<ReelFeedAndActionBloc>()
                        .add(LikeReel(likeData: likeData));
                  },
                  shareLink: videoItem.videoUrl,
                  onShareTap: () {
                    final postReelBloc = context.read<ReelFeedAndActionBloc>();
                    postReelBloc.add(ShareReel(reelId: videoItem.id));
                  },
                  currentUserId: currentUserId);
            },
          ),
        ),
      ],
    );
  }
}
