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
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: context.responsive<Widget>(
          sm: _MobilePostCard(post: post, onDeleted: onDeleted),
          md: _TabletPostCard(post: post, onDeleted: onDeleted),
        ),
      ),
    );
  }
}

void _showStarReactionModal(BuildContext context, Post post) {
  final walletService = Provider.of<WalletService>(context, listen: false);

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
                AppStrings.connectWallet.tr(context),
                style: TextStyle(
                  color: Color.fromRGBO(143, 148, 251, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            AppStrings.pleaseConnectWalletToSendStarReactions.tr(context),
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.cancel.tr(context),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).go(RouteNames.wallet);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                AppStrings.connectWallet.tr(context),
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

  if (!walletService.areContractsLoaded ||
      walletService.connectedAddress == null ||
      walletService.connectedNetwork?.chainId != walletService.sepoliaChainId) {
    walletService.appKitModal.onModalError.broadcast(
      ModalError(
        AppStrings.pleaseConnectToSepoliaNetworkToGiftStars.tr(context),
      ),
    );
    return;
  }

  final recipientAddressString = '0x6ed5aD6f949b27EDA88C47d1e3b9Eb3DE9140cfE';
  final recipientName =
      "${post.owner?.firstName ?? ''} ${post.owner?.lastName ?? ''}".trim();

  if (recipientAddressString.isEmpty) {
    walletService.appKitModal.onModalError.broadcast(
      ModalError(
        AppStrings.recipientWalletAddressNotAvailableForThisPostAuthor.tr(
          context,
        ),
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
      ModalError(
        AppStrings.invalidRecipientAddressFormatForThisPostAuthor.tr(context),
      ),
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
        recipientName: recipientName.isNotEmpty
            ? recipientName
            : AppStrings.postAuthor.tr(context),
        recipientAddress: recipientAddressString,
        recipientId: post.owner?.id ?? '',
      );
    },
  ).then((amountInStars) {
    if (amountInStars != null && amountInStars > 0) {
      print('Modal returned amount: $amountInStars. Initiating gift...');
      walletService.sendGiftStars(
        recipientAddressString,
        amountInStars,
        post.owner?.id ?? '',
      );
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(post: post, onDeleted: onDeleted),
        SizedBox(height: 10),
        if (post.content.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: post.files.isNotEmpty ? 12 : 16,
            ),
            child: _PostContent(content: post.content),
          ),
        if (post.files.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PostMedia(files: post.files),
          ),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.files.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _PostMedia(files: post.files),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PostHeader(post: post, onDeleted: onDeleted),
                    SizedBox(height: 10),
                    if (post.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 16,
                        ),
                        child: _PostContent(content: post.content),
                      ),
                  ],
                ),
                _PostActions(post: post),
              ],
            ),
          ),
        ],
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
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          post.owner?.profilePic != null && post.owner!.profilePic!.isNotEmpty
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    post.owner!.profilePic!,
                  ),
                )
              : const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 18),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${post.owner?.firstName} ${post.owner?.lastName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  dateFormat.format(post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _showPostOptions(context, post, onDeleted),
            icon: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final String content;

  const _PostContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    final parts = <String>[];

    if (matches.isEmpty) {
      return Text(content, style: const TextStyle(fontSize: 15, height: 1.4));
    }

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

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 15, height: 1.4),
        children: parts.map((part) {
          if (mentionRegex.hasMatch(part)) {
            return TextSpan(
              text: part,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  final username = part.substring(1);
                  context.push('${RouteNames.profile}/$username');
                },
            );
          }
          return TextSpan(text: part);
        }).toList(),
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
      return _buildMediaGrid(items: videoFiles, isVideo: true);
    }

    return _buildMediaGrid(
      items: imageFiles,
      isVideo: false,
      onImageTap: (index) => _openImageGallery(context, imageFiles, index),
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
    if (isVideo) {
      return Container(
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: _VideoItem(url: url, width: width, height: width * 9 / 16),
      );
    }

    return Container(
      width: width,
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: _ImageItem(url: url, onTap: onImageTap),
    );
  }

  Widget _buildTwoItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final itemWidth = (width - spacing) / 2;

    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: spacing / 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isVideo
                  ? _VideoItem(
                      url: urls[0],
                      width: itemWidth,
                      height: itemWidth,
                    )
                  : _ImageItem(url: urls[0], onTap: () => onImageTap?.call(0)),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: spacing / 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isVideo
                  ? _VideoItem(
                      url: urls[1],
                      width: itemWidth,
                      height: itemWidth,
                    )
                  : _ImageItem(url: urls[1], onTap: () => onImageTap?.call(1)),
            ),
          ),
        ),
      ],
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: leftWidth,
          margin: EdgeInsets.only(right: spacing / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? _VideoItem(url: urls[0], width: leftWidth, height: leftWidth)
                : _ImageItem(url: urls[0], onTap: () => onImageTap?.call(0)),
          ),
        ),
        Column(
          children: [
            Container(
              width: rightWidth,
              margin: EdgeInsets.only(bottom: spacing / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isVideo
                    ? _VideoItem(
                        url: urls[1],
                        width: rightWidth,
                        height: rightWidth,
                      )
                    : _ImageItem(
                        url: urls[1],
                        onTap: () => onImageTap?.call(1),
                      ),
              ),
            ),
            Container(
              width: rightWidth,
              margin: EdgeInsets.only(top: spacing / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isVideo
                    ? _VideoItem(
                        url: urls[2],
                        width: rightWidth,
                        height: rightWidth,
                      )
                    : _ImageItem(
                        url: urls[2],
                        onTap: () => onImageTap?.call(2),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFourItems(
    List<String> urls,
    double width,
    bool isVideo, {
    Function(int)? onImageTap,
  }) {
    final itemSize = (width - spacing) / 2;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: spacing / 2,
                  bottom: spacing / 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? _VideoItem(
                          url: urls[0],
                          width: itemSize,
                          height: itemSize,
                        )
                      : _ImageItem(
                          url: urls[0],
                          onTap: () => onImageTap?.call(0),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: spacing / 2, bottom: spacing / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? _VideoItem(
                          url: urls[1],
                          width: itemSize,
                          height: itemSize,
                        )
                      : _ImageItem(
                          url: urls[1],
                          onTap: () => onImageTap?.call(1),
                        ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: spacing / 2, top: spacing / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? _VideoItem(
                          url: urls[2],
                          width: itemSize,
                          height: itemSize,
                        )
                      : _ImageItem(
                          url: urls[2],
                          onTap: () => onImageTap?.call(2),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: spacing / 2, top: spacing / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? _VideoItem(
                          url: urls[3],
                          width: itemSize,
                          height: itemSize,
                        )
                      : _ImageItem(
                          url: urls[3],
                          onTap: () => onImageTap?.call(3),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
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

    return Row(
      children: [
        Container(
          width: itemSize,
          margin: EdgeInsets.only(right: spacing / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? _VideoItem(url: urls[0], width: itemSize, height: itemSize)
                : _ImageItem(url: urls[0], onTap: () => onImageTap?.call(0)),
          ),
        ),
        Container(
          width: itemSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade100,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? _VideoItem(url: urls[1], width: itemSize, height: itemSize)
                : _ImageItem(url: urls[1], onTap: () => onImageTap?.call(1)),
          ),
        ),
        Stack(
          children: [
            Container(
              width: itemSize,
              margin: EdgeInsets.only(left: spacing / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isVideo
                    ? _VideoItem(
                        url: urls[2],
                        width: itemSize,
                        height: itemSize,
                      )
                    : _ImageItem(
                        url: urls[2],
                        onTap: () => onImageTap?.call(2),
                      ),
              ),
            ),
            if (remainingCount > 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: !isVideo ? () => onImageTap?.call(2) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black54,
                    ),
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
      ],
    );
  }
}

class _ImageItem extends StatefulWidget {
  final String url;
  final VoidCallback? onTap;

  const _ImageItem({required this.url, this.onTap});

  @override
  _ImageItemState createState() => _ImageItemState();
}

class _ImageItemState extends State<_ImageItem> {
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _fetchImageDimensions();
  }

  Future<void> _fetchImageDimensions() async {
    final imageProvider = CachedNetworkImageProvider(widget.url);
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    imageStream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool synchronousCall) {
          if (mounted) {
            setState(() {
              _aspectRatio = info.image.width / info.image.height;
            });
          }
        },
        onError: (exception, stackTrace) {
          if (mounted) {
            setState(() {
              _aspectRatio = 1; // Default to square aspect ratio
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxHeight = screenWidth * 1.1; // 110% of screen width

    return GestureDetector(
      onTap: widget.onTap,
      child: _aspectRatio == null
          ? Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              width: screenWidth,
              height: maxHeight,
              child: CachedNetworkImage(
                imageUrl: widget.url,
                fit: BoxFit.cover,
                width: screenWidth,
                alignment: Alignment
                    .center, // Center alignment for equal top/bottom cropping
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _LikeButton(post: post)),
          Expanded(child: _CommentButton(post: post)),
          Expanded(child: _ShareButton(post: post)),
          Expanded(
            child: PostButton(
              icon: Icon(LucideIcons.star),
              text: AppStrings.gift.tr(context),
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
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    AppStrings.pleaseLoginToLikePosts.tr(context),
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
      text: AppStrings.share.tr(context),
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
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            AppStrings.failedToSharePost.tr(context),
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
  final prefs = await SharedPreferences.getInstance();
  final currentUserId = prefs.getString('userId');
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
              title: Text(
                AppStrings.reportPostTitle.tr(context),
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => context.push(RouteNames.reportPost, extra: post.id),
            ),
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppStrings.editPost.tr(context)),
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
                title: Text(AppStrings.deletePost.tr(context)),
                onTap: () {
                  context.read<PostBloc>().add(DeletePost(post.id));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.postDeletedSuccess.tr(context),
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
              title: Text(AppStrings.repostPost.tr(context)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      AppStrings.postReposted.tr(context),
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
