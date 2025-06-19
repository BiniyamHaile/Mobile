import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/likeable_type.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/views/reel/widgets/optimized_video_player.dart';
import 'package:mobile/ui/views/reel/widgets/video_overlay_section.dart';
import 'package:mobile/ui/widgets/wallet/star_reaction_modal.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/modal/models/public/appkit_modal_events.dart';
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

  void _showStarReactionModal(
    BuildContext context,
    String recipientAddressString,
  ) {
    final walletService = Provider.of<WalletService>(context, listen: false);

    // Check wallet connection first
    if (!walletService.isConnected || walletService.currentSession == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color.fromRGBO(143, 148, 251, 0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(143, 148, 251, 0.1),
                          Color.fromRGBO(143, 148, 251, 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(143, 148, 251, 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.wallet,
                            color: Color.fromRGBO(143, 148, 251, 1),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Connect Wallet',
                          style: TextStyle(
                            color: Color.fromRGBO(143, 148, 251, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Please connect your wallet to send star reactions.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            GoRouter.of(context).go(RouteNames.wallet);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Connect Wallet',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    // Check network and contracts after wallet connection
    if (!walletService.areContractsLoaded ||
        walletService.connectedAddress == null ||
        walletService.connectedNetwork?.chainId !=
            walletService.sepoliaChainId) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Please connect to Sepolia network to gift stars.'),
      );
      return;
    }

    if (recipientAddressString.isEmpty) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Recipient wallet address not available for this video.'),
      );
      return;
    }

    try {
      if (!recipientAddressString.startsWith('0x') ||
          recipientAddressString.length != 42) {
        throw const FormatException("Invalid address format");
      }
    } catch (e) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Invalid recipient address format for this video.'),
      );
      print('Recipient address parsing error before modal: $e');
      return;
    }

    // Show the bottom sheet modal
    showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StarReactionModal(
          recipientName: videoItem.username ?? "Daniel Tilahun",
          recipientAddress: recipientAddressString,
          recipientId: videoItem.ownerId ?? '',
        );
      },
    ).then((amountInStars) {
      if (amountInStars != null && amountInStars > 0) {
        print('Modal returned amount: $amountInStars. Initiating gift...');
        walletService.sendGiftStars(
          recipientAddressString,
          amountInStars,
          videoItem.ownerId ?? '',
        );
      } else {
        print('Modal closed or no amount selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OptimizedVideoPlayer(controller: controller, videoId: videoItem.id),
        Align(
          alignment: Alignment.bottomCenter,
          child: BlocBuilder<ReelFeedAndActionBloc, ReelFeedAndActionState>(
            builder: (context, state) {
              // Determine if the current video is liked based on the Bloc state
              final isLiked = state.likedVideoIds.contains(videoItem.id);
              final gift = videoItem.walletId != "";

              return VideoOverlaySection(
                id: videoItem.id,
                profileImageUrl: videoItem.profileImageUrl,
                username: videoItem.username,
                description: videoItem.description,
                // isBookmarked needs to come from state or videoItem if dynamic
                isBookmarked:
                    videoItem.isBookmarked, // Assuming it's on videoItem
                isLiked: isLiked, // Use the state value
                likeCount: videoItem
                    .likeCount, // Assuming it's on videoItem (might need update from state too)
                commentCount: videoItem.commentCount, // Assuming on videoItem
                shareCount: videoItem.shareCount, // Assuming on videoItem
                onLikePressed: () {
                  // Create the data object for the like event
                  final likeData = CreateLikeDto(
                    userId: currentUserId,
                    targetId: videoItem.id,
                    onModel: LikeableType.reel,
                  );
                  // Dispatch the LikeReel event to the Bloc
                  context.read<ReelFeedAndActionBloc>().add(
                    LikeReel(likeData: likeData),
                  );
                },
                shareLink: videoItem
                    .videoUrl, // Assuming videoUrl is the shareable link
                onShareTap: () {
                  // Dispatch the ShareReel event to the Bloc
                  final postReelBloc = context.read<ReelFeedAndActionBloc>();
                  postReelBloc.add(ShareReel(reelId: videoItem.id));
                },
                // Add the new callback for the Gift Stars action
                onGiftStarsPressed: () => _showStarReactionModal(
                  context,
                  videoItem.walletId,
                ), // Pass the function
                currentUserId: currentUserId,
                ownerId: videoItem.ownerId, // Pass the ownerId
                gift: gift,
              );
            },
          ),
        ),
      ],
    );
  }
}
