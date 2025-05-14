import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/social/comment/comment_bloc.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class CommentTile extends StatefulWidget {
  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    required this.isReplying,
    required this.showReplyButton,
    required this.onEdit,
  });

  final Comment comment;
  final VoidCallback? onReply;
  final bool isReplying;
  final bool showReplyButton;
  final Function(String) onEdit;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  late Comment _currentComment;
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _currentComment = widget.comment;
    _initializeVideos();
  }

  void _initializeVideos() async {
    for (final file in _currentComment.files) {
      if (_isVideo(file)) {
        final controller = VideoPlayerController.network(file);
        await controller.initialize();
        controller.setLooping(true);
        controller.pause();
        _videoControllers[file] = controller;
      }
    }
  }

  bool _isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov');
  }

  @override
  void didUpdateWidget(CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comment != oldWidget.comment) {
      _videoControllers.forEach((_, c) => c.dispose());
      _videoControllers.clear();
      _currentComment = widget.comment;
      _initializeVideos();
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentOperationSuccess) {
          final updatedComment = state.comments.firstWhere(
            (c) => c.id == _currentComment.id,
            orElse: () => _currentComment,
          );

          if (updatedComment != _currentComment) {
            setState(() => _currentComment = updatedComment);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage:
                  NetworkImage("https://randomuser.me/api/portraits/men/1.jpg"),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bemni', // Replace with actual author name
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentComment.content,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontSize: theme.textTheme.bodyLarge?.fontSize,
                        ),
                      ),
                      if (_currentComment.files.isNotEmpty)
                        _buildMediaAttachments(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _CommentLikeButton(
                                likeCount: _currentComment.likeCount,
                                commentId: _currentComment.id,
                                isLiked: _currentComment.likedBy
                                    .contains('currentUserId'),
                              ),
                              const SizedBox(width: 16),
                              if (widget.showReplyButton)
                                PostButton(
                                  icon: const Icon(Icons.reply, size: 18),
                                  text: 'Reply',
                                  onTap: widget.onReply ?? () {},
                                ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 18),
                            onPressed: () => _showCommentOptions(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaAttachments() {
    return Column(
      children: _currentComment.files.map((file) {
        final isVideo = _isVideo(file);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isVideo
                ? _buildVideoPlayer(file)
                : CachedNetworkImage(
                    imageUrl: file,
                    fit: BoxFit.cover,
                    width: 100,
                    placeholder: (context, url) => Container(
                      height: 60,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoPlayer(String url) {
    if (!_videoControllers.containsKey(url)) {
      return Container(
        height: 100,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = _videoControllers[url]!;
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          if (!controller.value.isPlaying)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  void _showCommentOptions(BuildContext context) {
    final commentBloc = BlocProvider.of<CommentBloc>(context);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit(_currentComment.content);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                commentBloc.add(DeleteComment(_currentComment.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comment deleted successfully'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _CommentLikeButton extends StatelessWidget {
  const _CommentLikeButton({
    required this.likeCount,
    required this.commentId,
    required this.isLiked,
  });

  final int likeCount;
  final String commentId;
  final bool isLiked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PostButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_outline,
        color: isLiked ? theme.colorScheme.primary : null,
        size: 18,
      ),
      text: likeCount.toString(),
      onTap: () {
        if (isLiked) {
          // context.read<CommentBloc>().add(
          //       // UnlikeComment(commentId, 'currentUserId'), // Replace with actual user ID
          //     );
        } else {
          // context.read<CommentBloc>().add(
          //       // LikeComment(commentId, 'currentUserId'), // Replace with actual user ID
          //     );
        }
      },
    );
  }
}
