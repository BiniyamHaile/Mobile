import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/common/common.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/widgets/image_gallery.dart';
import 'package:mobile/ui/widgets/wallet/star_reaction_modal.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/modal/models/public/appkit_modal_events.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onDeleted;

  const PostCard({super.key, required this.post, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: context.responsive<Widget>(
        sm: _MobilePostCard(post: post, onDeleted: onDeleted),
        md: _TabletPostCard(post: post, onDeleted: onDeleted),
      ),
    );
  }
}

void _showStarReactionModal(BuildContext context, Post post) {
  final walletService = Provider.of<WalletService>(context, listen: false);

  // Check if wallet is connected first
  if (!walletService.isConnected || walletService.currentSession == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.wallet, color: Color.fromRGBO(143, 148, 251, 1)),
              SizedBox(width: 12),
              Text(
                'Connect Wallet',
                style: TextStyle(
                  color: Color.fromRGBO(143, 148, 251, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Please connect your wallet to send star reactions.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                GoRouter.of(context).go(RouteNames.wallet); // Navigate to wallet screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        );
      },
    );
    return;
  }

  // Check network and contracts after wallet connection
  if (!walletService.areContractsLoaded ||
      walletService.connectedAddress == null ||
      walletService.connectedNetwork?.chainId != walletService.sepoliaChainId) {
    walletService.appKitModal.onModalError.broadcast(
      ModalError('Please connect to Sepolia network to gift stars.'),
    );
    return;
  }

  final recipientAddressString = '0x6ed5aD6f949b27EDA88C47d1e3b9Eb3DE9140cfE';
  final recipientName =
      "${post.owner?.firstName ?? ''} ${post.owner?.lastName ?? ''}".trim();

  if (recipientAddressString.isEmpty) {
    walletService.appKitModal.onModalError.broadcast(
      ModalError(
        'Recipient wallet address not available for this post author.',
      ),
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
      ModalError('Invalid recipient address format for this post author.'),
    );
    print('Recipient address parsing error before modal: $e');
    return;
  }

  showModalBottomSheet<int?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StarReactionModal(
        recipientName: recipientName.isNotEmpty ? recipientName : "Post Author",
        recipientAddress: recipientAddressString,
      );
    },
  ).then((amountInStars) {
    if (amountInStars != null && amountInStars > 0) {
      print('Modal returned amount: $amountInStars. Initiating gift...');
      walletService.sendGiftStars(recipientAddressString, amountInStars);
    } else {
      print('Modal closed or no amount selected.');
    }
  });
}

class _MobilePostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onDeleted;

  const _MobilePostCard({required this.post, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PostHeader(post: post, onDeleted: onDeleted),
        if (post.content.isNotEmpty) _PostContent(content: post.content),
        if (post.files.isNotEmpty) _PostMedia(files: post.files),
        _PostActions(post: post),
      ],
    );
  }
}

class _TabletPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onDeleted;

  const _TabletPostCard({required this.post, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.files.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _PostMedia(files: post.files),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PostHeader(post: post, onDeleted: onDeleted),
                        if (post.content.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _PostContent(content: post.content),
                          ),
                      ],
                    ),
                    _PostActions(post: post),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Post post;
  final VoidCallback? onDeleted;

  const _PostHeader({required this.post, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat(
      'MMM d, y • h:mm a',
    ); // Format: Jan 1, 2023 • 12:30 PM

    return ListTile(
      onTap: () => context.push(RouteNames.profile),
      leading:
          post.owner?.profilePic != null && post.owner!.profilePic!.isNotEmpty
          ? CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                post.owner!.profilePic!,
              ),
            )
          : const CircleAvatar(
              foregroundColor: Colors.red,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${post.owner?.firstName} ${post.owner?.lastName}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            dateFormat.format(post.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _showPostOptions(context, post, onDeleted),
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final String content;

  const _PostContent({required this.content});

  @override
  Widget build(BuildContext context) {
    // Regular expression to find mentions (@username)
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    final parts = <String>[];

    // If no mentions, return simple text
    if (matches.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text(content, style: const TextStyle(fontSize: 16)),
        ),
      );
    }

    // Split content into text and mentions
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        parts.add(content.substring(lastEnd, match.start));
      }
      parts.add(content.substring(match.start, match.end));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      parts.add(content.substring(lastEnd));
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
            children: parts.map((part) {
              if (mentionRegex.hasMatch(part)) {
                return TextSpan(
                  text: part,
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Remove @ symbol and navigate to profile
                      final username = part.substring(1);
                      context.push('${RouteNames.profile}/$username');
                    },
                );
              }
              return TextSpan(text: part);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final List<String> files;
  static const double spacing = 4.0;

  const _PostMedia({required this.files});

  @override
  Widget build(BuildContext context) {
    final videoFiles = files
        .where(
          (file) =>
              file.toLowerCase().endsWith('.mp4') ||
              file.toLowerCase().contains('video'),
        )
        .toList();

    final imageFiles = files
        .where((file) => !videoFiles.contains(file))
        .toList();

    if (videoFiles.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _buildMediaGrid(items: videoFiles, isVideo: true),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: _buildMediaGrid(
        items: imageFiles,
        isVideo: false,
        onImageTap: (index) => _openImageGallery(context, imageFiles, index),
      ),
    );
  }

  void _openImageGallery(BuildContext context, List<String> images, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageGalleryScreen(imageUrls: images, initialIndex: index),
      ),
    );
  }

  Widget _buildMediaGrid({
    required List<String> items,
    required bool isVideo,
    Function(int)? onImageTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (items.isEmpty) return const SizedBox();
        if (items.length == 1)
          return _buildSingleItem(
            items[0],
            maxWidth,
            isVideo,
            onImageTap: () => onImageTap?.call(0),
          );
        if (items.length == 2)
          return _buildTwoItems(
            items,
            maxWidth,
            isVideo,
            onImageTap: onImageTap,
          );
        if (items.length == 3)
          return _buildThreeItems(
            items,
            maxWidth,
            isVideo,
            onImageTap: onImageTap,
          );
        if (items.length == 4)
          return _buildFourItems(
            items,
            maxWidth,
            isVideo,
            onImageTap: onImageTap,
          );
        return _buildMultiItems(
          items,
          maxWidth,
          isVideo,
          onImageTap: onImageTap,
        );
      },
    );
  }

  Widget _buildSingleItem(
    String url,
    double width,
    bool isVideo, {
    VoidCallback? onImageTap,
  }) {
    return GestureDetector(
      onTap: !isVideo ? onImageTap : null,
      child: isVideo
          ? _VideoItem(url: url, width: width, height: width * 9 / 16)
          : _ImageItem(url: url, width: width, height: width),
    );
  }

  Widget _buildTwoItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final itemWidth = (width - spacing) / 2;
    final height = isVideo ? itemWidth * 1.2 : itemWidth;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: !isVideo ? () => onImageTap?.call(0) : null,
              child: Container(
                margin: EdgeInsets.only(right: spacing / 2),
                child: isVideo
                    ? _VideoItem(url: urls[0], width: itemWidth, height: height)
                    : _ImageItem(
                        url: urls[0],
                        width: itemWidth,
                        height: height,
                      ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: !isVideo ? () => onImageTap?.call(1) : null,
              child: Container(
                margin: EdgeInsets.only(left: spacing / 2),
                child: isVideo
                    ? _VideoItem(url: urls[1], width: itemWidth, height: height)
                    : _ImageItem(
                        url: urls[1],
                        width: itemWidth,
                        height: height,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final leftWidth = (width - spacing) * 0.6;
    final rightWidth = (width - spacing) * 0.4;
    final leftHeight = isVideo ? leftWidth * 1.1 : leftWidth;

    return SizedBox(
      height: leftHeight,
      child: Row(
        children: [
          GestureDetector(
            onTap: !isVideo ? () => onImageTap?.call(0) : null,
            child: Container(
              width: leftWidth,
              height: leftHeight,
              margin: EdgeInsets.only(right: spacing / 2),
              child: isVideo
                  ? _VideoItem(
                      url: urls[0],
                      width: leftWidth,
                      height: leftHeight,
                    )
                  : _ImageItem(
                      url: urls[0],
                      width: leftWidth,
                      height: leftHeight,
                    ),
            ),
          ),
          Container(
            width: rightWidth,
            height: leftHeight,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(1) : null,
                    child: Container(
                      margin: EdgeInsets.only(bottom: spacing / 2),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[1],
                              width: rightWidth,
                              height: null,
                            )
                          : _ImageItem(
                              url: urls[1],
                              width: rightWidth,
                              height: null,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(2) : null,
                    child: Container(
                      margin: EdgeInsets.only(top: spacing / 2),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[2],
                              width: rightWidth,
                              height: null,
                            )
                          : _ImageItem(
                              url: urls[2],
                              width: rightWidth,
                              height: null,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final itemSize = (width - spacing) / 2;
    final height = isVideo ? itemSize : itemSize;

    return SizedBox(
      height: height * 2 + spacing,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(0) : null,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: spacing / 2,
                        bottom: spacing / 2,
                      ),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[0],
                              width: itemSize,
                              height: height,
                            )
                          : _ImageItem(
                              url: urls[0],
                              width: itemSize,
                              height: height,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(1) : null,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: spacing / 2,
                        bottom: spacing / 2,
                      ),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[1],
                              width: itemSize,
                              height: height,
                            )
                          : _ImageItem(
                              url: urls[1],
                              width: itemSize,
                              height: height,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(2) : null,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: spacing / 2,
                        top: spacing / 2,
                      ),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[2],
                              width: itemSize,
                              height: height,
                            )
                          : _ImageItem(
                              url: urls[2],
                              width: itemSize,
                              height: height,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: !isVideo ? () => onImageTap?.call(3) : null,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: spacing / 2,
                        top: spacing / 2,
                      ),
                      child: isVideo
                          ? _VideoItem(
                              url: urls[3],
                              width: itemSize,
                              height: height,
                            )
                          : _ImageItem(
                              url: urls[3],
                              width: itemSize,
                              height: height,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final itemSize = (width - spacing * 2) / 3;
    final remainingCount = urls.length - 3;
    final height = isVideo ? itemSize : itemSize;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: !isVideo ? () => onImageTap?.call(0) : null,
            child: Container(
              width: itemSize,
              height: height,
              margin: EdgeInsets.only(right: spacing / 2),
              child: isVideo
                  ? _VideoItem(url: urls[0], width: itemSize, height: height)
                  : _ImageItem(url: urls[0], width: itemSize, height: height),
            ),
          ),
          GestureDetector(
            onTap: !isVideo ? () => onImageTap?.call(1) : null,
            child: Container(
              width: itemSize,
              height: height,
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: isVideo
                  ? _VideoItem(url: urls[1], width: itemSize, height: height)
                  : _ImageItem(url: urls[1], width: itemSize, height: height),
            ),
          ),
          GestureDetector(
            onTap: !isVideo ? () => onImageTap?.call(2) : null,
            child: Stack(
              children: [
                Container(
                  width: itemSize,
                  height: height,
                  margin: EdgeInsets.only(left: spacing / 2),
                  child: isVideo
                      ? _VideoItem(
                          url: urls[2],
                          width: itemSize,
                          height: height,
                        )
                      : _ImageItem(
                          url: urls[2],
                          width: itemSize,
                          height: height,
                        ),
                ),
                if (remainingCount > 0)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: !isVideo ? () => onImageTap?.call(2) : null,
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Text(
                            '+$remainingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  final String url;
  final double width;
  final double? height;

  const _ImageItem({required this.url, required this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
        // ignore: unnecessary_null_comparison
        memCacheWidth: width != null ? (width * 2).toInt() : null,
      ),
    );
  }
}

class CachedVideoPlayer extends StatefulWidget {
  final String url;
  final bool showControls;
  final bool looping;
  final bool autoPlay;

  const CachedVideoPlayer({
    required this.url,
    this.showControls = true,
    this.looping = false,
    this.autoPlay = false,
    Key? key,
  }) : super(key: key);

  @override
  _CachedVideoPlayerState createState() => _CachedVideoPlayerState();
}

class _CachedVideoPlayerState extends State<CachedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // Get cached file or download if not cached
    final file = await DefaultCacheManager().getSingleFile(widget.url);

    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController.initialize();

    if (widget.showControls) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: true,
        placeholder: Container(color: Colors.grey),
        autoInitialize: true,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return widget.showControls
        ? Chewie(controller: _chewieController!)
        : AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          );
  }
}

class _VideoItem extends StatelessWidget {
  final String url;
  final double width;
  final double? height;

  const _VideoItem({required this.url, required this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: CachedVideoPlayer(url: url, showControls: true),
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final Post post;

  const _PostActions({required this.post});

  @override
  Widget build(BuildContext context) {
    final showGiftButton =
        post.owner?.walletAddress != null &&
        post.owner!.walletAddress!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _LikeButton(post: post)),
          Expanded(child: _CommentButton(post: post)),
          Expanded(child: _ShareButton(post: post)),

          // if (showGiftButton) // Show only if the condition is true
          //   Expanded(
          //     child: PostButton(
          //       // Assuming LucideIcons is available and imported
          //       icon: Icon(LucideIcons.star),
          //       text: 'Gift', // Or 'Stars', 'Tip', etc.
          //       onTap: () {
          //         // Call the helper function defined above
          //         _showStarReactionModal(context, post);
          //       },
          //     ),
          //   ),
          Expanded(
            child: PostButton(
              icon: Icon(LucideIcons.star),
              text: 'Gift',
              onTap: () {
                _showStarReactionModal(context, post);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatefulWidget {
  final Post post;

  const _LikeButton({required this.post});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        final isLiked = currentUserId != null
            ? widget.post.likedBy.contains(currentUserId)
            : false;
        final likeCount = widget.post.likedBy.length;

        return PostButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_outline,
            color: isLiked ? Colors.red : null,
          ),
          text: likeCount.toString(),
          onTap: () {
            if (currentUserId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    'Please login to like posts',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
              return;
            }
            context.read<PostBloc>().add(
              ToggleReaction(postId: widget.post.id),
            );
          },
        );
      },
    );
  }
}

class _CommentButton extends StatefulWidget {
  final Post post;

  const _CommentButton({required this.post});

  @override
  State<_CommentButton> createState() => _CommentButtonState();
}

class _CommentButtonState extends State<_CommentButton> {
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.post.commentIds.length;
  }

  @override
  Widget build(BuildContext context) {
    return PostButton(
      icon: const Icon(Icons.chat_bubble_outline),
      text: _commentCount.toString(),
      onTap: () =>
          CommentsBottomSheet.showCommentsBottomSheet(
            context,
            post: widget.post,
          ).then((_) {
            setState(() => _commentCount = widget.post.commentIds.length);
          }),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final Post post;

  const _ShareButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return PostButton(
      icon: const Icon(Icons.share_outlined),
      text: 'Share',
      onTap: () => _sharePost(context),
    );
  }

  Future<void> _sharePost(BuildContext context) async {
    try {
      await Share.share(
        'Check out this post: http://example.com/posts/${post.id}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to share post',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}

void _showPostOptions(
  BuildContext context,
  Post post,
  VoidCallback? onDeleted,
) async {
  // Get current user ID from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final currentUserId = prefs.getString('userId');

  // Check if current user is the post owner
  final isOwner =
      currentUserId != null &&
      post.owner != null &&
      post.owner!.id == currentUserId;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text(
                'Report Post',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => context.push(RouteNames.reportPost, extra: post.id),
            ),
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostingScreen(post: post),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Post'),
                onTap: () {
                  context.read<PostBloc>().add(DeletePost(post.id));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Post deleted',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  if (onDeleted != null) {
                    onDeleted();
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repost Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      'Post reposted',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
