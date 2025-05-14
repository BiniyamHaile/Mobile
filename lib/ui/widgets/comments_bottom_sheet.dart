import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:mobile/bloc/social/comment/comment_bloc.dart';
import 'package:mobile/models/models.dart';
import 'package:mobile/repository/social/comment_repository.dart';
import 'package:mobile/ui/widgets/comment_tile.dart';

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({super.key, required this.post});

  static Future<void> showCommentsBottomSheet(
    BuildContext context, {
    required Post post,
  }) async {
    return await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      enableDrag: true,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: BlocProvider(
          create: (context) => CommentBloc(
            commentRepository: CommentRepository(),
          )..add(LoadComments(post.id)),
          child: CommentsBottomSheet(post: post),
        ),
      ),
    );
  }

  final Post post;

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedMedia = [];
  final Map<String, VideoPlayerController> _videoControllers = {};
  String? _replyingToCommentId;
  String? _replyingToUsername;
  String? _editingCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _videoControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (pickedFiles.isNotEmpty && mounted) {
        setState(() => _selectedMedia.addAll(pickedFiles));
      }
    } catch (e) {
      if (mounted) _showError('Error selecting photos');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (pickedFile != null && mounted) {
        final controller = VideoPlayerController.file(File(pickedFile.path));
        await controller.initialize();
        controller.setLooping(true);
        controller.pause();
        setState(() {
          _selectedMedia.add(pickedFile);
          _videoControllers[pickedFile.path] = controller;
        });
      }
    } catch (e) {
      if (mounted) _showError('Error selecting video');
    }
  }

  void _removeMedia(int index) {
    final removed = _selectedMedia.removeAt(index);
    _videoControllers.remove(removed.path)?.dispose();
    setState(() {});
  }

  Widget _buildMediaPreview() {
    if (_selectedMedia.isEmpty) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedMedia.length,
            itemBuilder: (context, index) {
              final file = _selectedMedia[index];
              final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
                  file.path.toLowerCase().endsWith('.mov');

              Widget mediaWidget;

              if (isVideo) {
                final controller = _videoControllers[file.path];
                if (controller != null && controller.value.isInitialized) {
                  mediaWidget = AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  mediaWidget =
                      const Center(child: CircularProgressIndicator());
                }
              } else {
                mediaWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: mediaWidget,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeMedia(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentOperationSuccess) {
          if (_editingCommentId == null) {
            _commentController.clear();
            _selectedMedia.clear();
            _videoControllers.clear();
          }
          _setReplyingTo(null, null);
          _editingCommentId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is CommentError) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: _buildCommentsList(state),
                ),
              ),
              _header(theme),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _commentTextField(theme, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsList(CommentState state) {
    if (state is CommentLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is CommentsLoaded || state is CommentOperationSuccess) {
      final comments = (state is CommentsLoaded)
          ? state.comments
          : (state as CommentOperationSuccess).comments;

      final topLevelComments =
          comments.where((c) => c.parentId == null).toList();

      return ListView.builder(
        itemCount: topLevelComments.length,
        itemBuilder: (_, index) {
          final comment = topLevelComments[index];
          final replies =
              comments.where((c) => c.parentId == comment.id).toList();

          return Column(
            children: [
              if (index == 0) const SizedBox(height: 16),
              CommentTile(
                comment: comment,
                onReply: () => _setReplyingTo(comment.id, 'User'),
                isReplying: _replyingToCommentId == comment.id,
                showReplyButton: true,
                onEdit: (content) {
                  _editingCommentId = comment.id;
                  _commentController.text = content;
                  _commentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: content.length),
                  );
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              if (replies.isNotEmpty) ..._buildReplies(replies, indentLevel: 1),
            ],
          );
        },
      );
    } else if (state is CommentError) {
      return Center(child: Text(state.message));
    }
    return const Center(child: CircularProgressIndicator());
  }

  List<Widget> _buildReplies(List<Comment> replies, {int indentLevel = 1}) {
    return replies.map((reply) {
      final allComments = context.read<CommentBloc>().state;
      List<Comment> nestedReplies = [];

      if (allComments is CommentsLoaded ||
          allComments is CommentOperationSuccess) {
        nestedReplies = (allComments is CommentsLoaded
                ? allComments.comments
                : (allComments as CommentOperationSuccess).comments)
            .where((c) => c.parentId == reply.id)
            .toList();
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 40.0 * indentLevel),
            child: CommentTile(
              comment: reply,
              onReply: () => _setReplyingTo(reply.id, 'User'),
              isReplying: _replyingToCommentId == reply.id,
              showReplyButton: true,
              onEdit: (content) {
                _editingCommentId = reply.id;
                _commentController.text = content;
                _commentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: content.length),
                );
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
          ),
          if (nestedReplies.isNotEmpty)
            ..._buildReplies(nestedReplies, indentLevel: indentLevel + 1),
        ],
      );
    }).toList();
  }

  void _setReplyingTo(String? commentId, String? username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
      _editingCommentId = null;
      _commentController.text = commentId != null ? '@$username ' : '';
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentController.text.length),
      );
    });
  }

  Widget _header(ThemeData theme) {
    return SizedBox(
      height: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: theme.dividerColor.withAlpha(100),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 100),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTextField(ThemeData theme, CommentState state) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyingToCommentId != null || _editingCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    _editingCommentId != null
                        ? 'Editing comment'
                        : 'Replying to $_replyingToUsername',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      _setReplyingTo(null, null);
                      _editingCommentId = null;
                      _selectedMedia.clear();
                      _videoControllers.clear();
                    },
                  ),
                ],
              ),
            ),
          _buildMediaPreview(),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: const Icon(Icons.video_library),
                onPressed: _pickVideo,
              ),
              Expanded(
                  child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: _editingCommentId != null
                      ? 'Edit your comment...'
                      : _replyingToCommentId != null
                          ? 'Write a reply...'
                          : 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300, // Subtle border color
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.black, // Accent color when focused
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                maxLines: 5,
                minLines: 1,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  height: 1.4, // Better line spacing
                ),
                cursorColor: Colors.blue.shade600,
                textCapitalization: TextCapitalization.sentences,
              )),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _submitComment(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(BuildContext context) {
    if (_commentController.text.isEmpty && _selectedMedia.isEmpty) {
      _showError('Please add text or media');
      return;
    }

    final currentState = context.read<CommentBloc>().state;
    if (currentState is CommentLoading) return;

    if (_editingCommentId != null) {
      context.read<CommentBloc>().add(
            UpdateComment(
              commentId: _editingCommentId!,
              content: _commentController.text,
              files: _selectedMedia,
            ),
          );
    } else {
      context.read<CommentBloc>().add(
            CreateComment(
              postId: widget.post.id,
              content: _commentController.text,
              parentId: _replyingToCommentId,
              files: _selectedMedia,
            ),
          );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
