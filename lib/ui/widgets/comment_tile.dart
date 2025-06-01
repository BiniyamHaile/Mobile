import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/bloc/social/comment/comment_bloc.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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
  final Map<String, ChewieController> _chewieControllers = {};
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _currentComment = widget.comment;
    _initializeVideos();
    _loadUserId();
  }

  void _initializeVideos() async {
    for (final file in _currentComment.files) {
      if (_isVideo(file)) {
        final controller = VideoPlayerController.network(file);
        await controller.initialize();
        controller.setLooping(true);
        controller.pause();
        _videoControllers[file] = controller;
        
        _chewieControllers[file] = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: true,
          showControls: false,
          allowFullScreen: false,
        );
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
      _chewieControllers.forEach((_, c) => c.dispose());
      _videoControllers.clear();
      _chewieControllers.clear();
      _currentComment = widget.comment;
      _initializeVideos();
    }
  }

  @override
  void dispose() {
    _videoControllers.forEach((_, c) => c.dispose());
    _chewieControllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
  }

  void _showFullScreenMedia(BuildContext context, String url, bool isVideo) {
    if (isVideo) {
      final controller = _videoControllers[url];
      if (controller != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1), // Add this lin
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: Chewie(
                  controller: ChewieController(
                    videoPlayerController: controller,
                    autoPlay: true,
                    looping: true,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }
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
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  (_currentComment.owner?.profilePic?.isNotEmpty ?? false)
                      ? CachedNetworkImageProvider('${_currentComment.owner?.profilePic}')
                      : null,
              child: (_currentComment.owner?.profilePic?.isNotEmpty ?? false)
                  ? null
                  : Icon(Icons.person, color: Colors.grey.shade800),
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
                      Row(
                        children: [
                          Text(
                            "${_currentComment.owner?.firstName} ${_currentComment.owner?.lastName}",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(_currentComment.createdAt),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_currentComment.content.isNotEmpty)
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
                                commentId: _currentComment.id,
                                initialLikeCount: _currentComment.likeCount,
                                initialIsLiked: _currentComment.likedBy
                                    .contains(currentUserId),
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
                          if (currentUserId != null &&
                              _currentComment.owner?.id == currentUserId) ...[
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onPressed: () =>
                                  _showCommentOptions(context, _currentComment),
                            ),
                          ],
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
          child: GestureDetector(
            onTap: () => _showFullScreenMedia(context, file, isVideo),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    isVideo
                        ? _buildVideoThumbnail(file)
                        : CachedNetworkImage(
                            imageUrl: file,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 300,
                            placeholder: (context, url) => Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.error,
                                size: 50,
                                color: Colors.red,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVideoThumbnail(String url) {
    if (!_chewieControllers.containsKey(url)) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final chewieController = _chewieControllers[url]!;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 300,
          child: AspectRatio(
            aspectRatio: chewieController.videoPlayerController.value.aspectRatio,
            child: Chewie(controller: chewieController),
          ),
        ),
        if (!chewieController.isPlaying)
          Container(
            height: 300,
            color: Colors.black.withOpacity(0.3),
            child: const Icon(
              Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  void _showCommentOptions(BuildContext context, Comment comment) async {
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

class _CommentLikeButton extends StatefulWidget {
  const _CommentLikeButton({
    required this.commentId,
    required this.initialLikeCount,
    required this.initialIsLiked,
  });

  final String commentId;
  final int initialLikeCount;
  final bool initialIsLiked;

  @override
  __CommentLikeButtonState createState() => __CommentLikeButtonState();
}

class __CommentLikeButtonState extends State<_CommentLikeButton> {
  late int _likeCount;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
    _isLiked = widget.initialIsLiked;
  }

  @override
  Widget build(BuildContext context) {
    return PostButton(
      icon: Icon(
        _isLiked ? Icons.favorite : Icons.favorite_outline,
        color: _isLiked ? Colors.red : null,
        size: 18,
      ),
      text: _likeCount.toString(),
      onTap: () {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
        });

        context
            .read<CommentBloc>()
            .add(ToggleReaction(commentId: widget.commentId));
      },
    );
  }
}