import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/social/post/post_bloc.dart';
import 'package:mobile/common/common.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/ui/pages/post/feed_page.dart';
import 'package:mobile/ui/pages/post/post_page.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/widgets/video_player_widget.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: context.responsive<Widget>(
        sm: _MobilePostCard(post: post),
        md: _TabletPostCard(post: post),
      ),
    );
  }
}

class _MobilePostCard extends StatelessWidget {
  final Post post;

  const _MobilePostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PostHeader(post: post),
        if (post.content.isNotEmpty) _PostContent(content: post.content),
        if (post.files.isNotEmpty) _PostMedia(files: post.files),
        _PostActions(post: post),
      ],
    );
  }
}

class _TabletPostCard extends StatelessWidget {
  final Post post;

  const _TabletPostCard({required this.post});

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
                        _PostHeader(post: post),
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

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push(RouteNames.profile),
      leading: const CircleAvatar(
        foregroundColor: Colors.red,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person),
      ),
      title: const Text(
        "Devali",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: IconButton(
        onPressed: () => _showPostOptions(context, post),
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
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16),
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
        .where((file) =>
            file.toLowerCase().endsWith('.mp4') ||
            file.toLowerCase().contains('video'))
        .toList();

    final imageFiles =
        files.where((file) => !videoFiles.contains(file)).toList();

    if (videoFiles.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: _buildMediaGrid(
          items: videoFiles,
          isVideo: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: _buildMediaGrid(
        items: imageFiles,
        isVideo: false,
      ),
    );
  }

  Widget _buildMediaGrid({
    required List<String> items,
    required bool isVideo,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        if (items.isEmpty) return const SizedBox();
        if (items.length == 1)
          return _buildSingleItem(items[0], maxWidth, isVideo);
        if (items.length == 2) return _buildTwoItems(items, maxWidth, isVideo);
        if (items.length == 3)
          return _buildThreeItems(items, maxWidth, isVideo);
        if (items.length == 4) return _buildFourItems(items, maxWidth, isVideo);
        return _buildMultiItems(items, maxWidth, isVideo);
      },
    );
  }

  Widget _buildSingleItem(String url, double width, bool isVideo) {
    return isVideo
        ? _VideoItem(url: url, width: width, height: width * 9 / 16)
        : _ImageItem(url: url, width: width, height: width);
  }

  Widget _buildTwoItems(List<String> urls, double width, bool isVideo) {
    final itemWidth = (width - spacing) / 2;
    final height = isVideo ? itemWidth * 1.2 : itemWidth;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(right: spacing / 2),
              child: isVideo
                  ? _VideoItem(url: urls[0], width: itemWidth, height: height)
                  : _ImageItem(url: urls[0], width: itemWidth, height: height),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: spacing / 2),
              child: isVideo
                  ? _VideoItem(url: urls[1], width: itemWidth, height: height)
                  : _ImageItem(url: urls[1], width: itemWidth, height: height),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeItems(List<String> urls, double width, bool isVideo) {
    final leftWidth = (width - spacing) * 0.6;
    final rightWidth = (width - spacing) * 0.4;
    final leftHeight = isVideo ? leftWidth * 1.1 : leftWidth;

    return SizedBox(
      height: leftHeight,
      child: Row(
        children: [
          Container(
            width: leftWidth,
            height: leftHeight,
            margin: EdgeInsets.only(right: spacing / 2),
            child: isVideo
                ? _VideoItem(url: urls[0], width: leftWidth, height: leftHeight)
                : _ImageItem(
                    url: urls[0], width: leftWidth, height: leftHeight),
          ),
          Container(
            width: rightWidth,
            height: leftHeight, // Match left side height
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[1], width: rightWidth, height: null)
                        : _ImageItem(
                            url: urls[1], width: rightWidth, height: null),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[2], width: rightWidth, height: null)
                        : _ImageItem(
                            url: urls[2], width: rightWidth, height: null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFourItems(List<String> urls, double width, bool isVideo) {
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
                  child: Container(
                    margin: EdgeInsets.only(
                        right: spacing / 2, bottom: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[0], width: itemSize, height: height)
                        : _ImageItem(
                            url: urls[0], width: itemSize, height: height),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(left: spacing / 2, bottom: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[1], width: itemSize, height: height)
                        : _ImageItem(
                            url: urls[1], width: itemSize, height: height),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(right: spacing / 2, top: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[2], width: itemSize, height: height)
                        : _ImageItem(
                            url: urls[2], width: itemSize, height: height),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin:
                        EdgeInsets.only(left: spacing / 2, top: spacing / 2),
                    child: isVideo
                        ? _VideoItem(
                            url: urls[3], width: itemSize, height: height)
                        : _ImageItem(
                            url: urls[3], width: itemSize, height: height),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiItems(List<String> urls, double width, bool isVideo) {
    final itemSize = (width - spacing * 2) / 3;
    final remainingCount = urls.length - 3;
    final height = isVideo ? itemSize : itemSize;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Container(
            width: itemSize,
            height: height,
            margin: EdgeInsets.only(right: spacing / 2),
            child: isVideo
                ? _VideoItem(url: urls[0], width: itemSize, height: height)
                : _ImageItem(url: urls[0], width: itemSize, height: height),
          ),
          Container(
            width: itemSize,
            height: height,
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: isVideo
                ? _VideoItem(url: urls[1], width: itemSize, height: height)
                : _ImageItem(url: urls[1], width: itemSize, height: height),
          ),
          Stack(
            children: [
              Container(
                width: itemSize,
                height: height,
                margin: EdgeInsets.only(left: spacing / 2),
                child: isVideo
                    ? _VideoItem(url: urls[2], width: itemSize, height: height)
                    : _ImageItem(url: urls[2], width: itemSize, height: height),
              ),
              if (remainingCount > 0)
                Positioned.fill(
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
            ],
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

  const _ImageItem({
    required this.url,
    required this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          return progress == null
              ? child
              : Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
        },
        errorBuilder: (ctx, _, __) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String url;
  final double width;
  final double? height;

  const _VideoItem({
    required this.url,
    required this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: VideoPlayerWidget(
          url: url,
          showControls: true,
        ),
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
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.likedBy.isNotEmpty;
    _likeCount = widget.post.likedBy.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PostButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_outline,
        color: _isLiked ? theme.colorScheme.primary : null,
      ),
      text: _likeCount.toString(),
      onTap: () {
        setState(() {
          _isLiked = !_isLiked;
          _isLiked ? _likeCount++ : _likeCount--;
        });
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
      onTap: () => CommentsBottomSheet.showCommentsBottomSheet(
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
        const SnackBar(content: Text('Failed to share post')),
      );
    }
  }
}

void _showPostOptions(BuildContext context, Post post) {
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
              title: const Text('Report Post',
                  style: TextStyle(color: Colors.red)),
              onTap: () => context.push(RouteNames.reportPost, extra: post.id),
            ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Repost'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reposted')),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
