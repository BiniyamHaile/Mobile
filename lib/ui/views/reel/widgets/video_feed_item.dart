import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/likeable_type.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
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

  // Function to show the Star Reaction Modal
  void _showStarReactionModal(BuildContext context , String recipientAddressString) {
    // Access WalletService using Provider
    final walletService = Provider.of<WalletService>(context, listen: false);

    if (!walletService.isConnected ||
        walletService.currentSession == null ||
        !walletService.areContractsLoaded ||
        walletService.connectedAddress == null ||
        walletService.connectedNetwork?.chainId !=
            walletService.sepoliaChainId) {
      // Use the modal error mechanism provided by WalletService
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Please connect to Sepolia network to gift stars.'),
      );
      return;
    }

    // Get recipient address. This originally came from a controller.
    // ASSUMPTION: The recipient address is available in the videoItem, e.g., videoItem.authorWalletAddress.
    // If not, you will need to find another way to get the recipient's wallet address.
    // final recipientAddressString =
    //     videoItem.authorWalletAddress;

    // final recipientAddressString = '0x6ed5aD6f949b27EDA88C47d1e3b9Eb3DE9140cfE';

    // <-- ASSUMPTION

    if (recipientAddressString == null || recipientAddressString.isEmpty) {
      // If no recipient address is available for this video item
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Recipient wallet address not available for this video.'),
      );
      return;
    }

    // Basic address format validation
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
      isScrollControlled:
          true, // Allows the modal to take up more screen space if needed
      backgroundColor: Colors
          .transparent, // Makes the background transparent (for rounded corners)
      builder: (BuildContext context) {
        return StarReactionModal(
          // You might want to pass the author's username if available in videoItem
          recipientName:
              videoItem.username ??
              "Daniel Tilahun", // <-- ASSUMPTION: username is available
          recipientAddress: recipientAddressString,
        );
      },
    ).then((amountInStars) {
      // This block is executed after the modal is closed.
      // amountInStars will be the value returned from the modal (or null if closed without selecting).
      if (amountInStars != null && amountInStars > 0) {
        print('Modal returned amount: $amountInStars. Initiating gift...');
        walletService.sendGiftStars(recipientAddressString, amountInStars);
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
                onGiftStarsPressed: () =>
                    _showStarReactionModal(context , videoItem.walletId), // Pass the function
                currentUserId: currentUserId,
                gift: gift
              );
            },
          ),
        ),
      ],
    );
  }
}
