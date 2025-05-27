import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/comment/comment_bloc.dart';
import 'package:mobile/bloc/comment/comment_event.dart';
import 'package:mobile/bloc/comment/comment_state.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/comment/comment.dart';
import 'package:mobile/models/reel/comment/dto/create_comment_dto.dart';
import 'package:mobile/models/reel/comment/dto/update_comment_dto.dart';
import 'package:mobile/ui/views/reel/widgets/comment_list.dart';
import 'package:mobile/ui/views/reel/widgets/new_comment.dart';

class CommentTreeData {
  final Comment rootComment;
  final List<Comment> replies;

  CommentTreeData({required this.rootComment, required this.replies});
}

class CommentSection extends StatefulWidget {
  final int commentCount;
  final String reelId;
  final VoidCallback onClose;
  final String currentUserId;

  const CommentSection({
    Key? key,
    required this.commentCount,
    required this.reelId,
    required this.onClose,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  String? _replyToCommentId;
  String? _replyToUserId;
  String? _replyToUserName;

  String? _editingCommentId;
  String? _editingCommentContent;

  final _scrollController = ScrollController();
  final int _commentsPerPage = 10;

  final TextEditingController _commentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CommentBloc>().loadInitialComments(widget.reelId);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentInputController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const scrollThreshold = 200.0;

    final state = context.read<CommentBloc>().state;

    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        currentScroll > maxScroll - scrollThreshold &&
        !state.isLoading &&
        state.hasMore) {
      context.read<CommentBloc>().loadNextPage(widget.reelId);
      print('Loading next page...');
    }
  }

  Map<String, CommentTreeData> _buildCommentTrees(List<Comment> comments) {
    Map<String, CommentTreeData> commentTrees = {};

    List<Comment> reelComments =
        comments.where((c) => c.reelId == widget.reelId).toList();

    List<Comment> rootComments =
        reelComments.where((comment) => comment.parentId == null).toList();

    rootComments.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    for (var rootComment in rootComments) {
      List<Comment> replies = reelComments
          .where((comment) => comment.parentId == rootComment.id)
          .toList();

      replies.sort(
        (a, b) => a.createdAt.compareTo(b.createdAt),
      );

      commentTrees[rootComment.id] = CommentTreeData(
        rootComment: rootComment,
        replies: replies,
      );
    }

    return commentTrees;
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    final newCommentDto = CreateCommentDto(
      content: text.trim(),
      reelId: widget.reelId,
      parentCommentId: _replyToCommentId,
    );

    print("Dispatching PostComment: $newCommentDto");

    context.read<CommentBloc>().add(
          PostComment(commentData: newCommentDto, reelId: widget.reelId),
        );

    _cancelReply();
    _commentInputController.clear();
  }

  void _handleUpdate(String newContent) {
    if (_editingCommentId == null || newContent.trim().isEmpty) return;

    final updateDto = UpdateCommentDto(content: newContent.trim());

    print(
      "Dispatching UpdateComment: id=$_editingCommentId, content=$newContent",
    );

    context.read<CommentBloc>().add(
          UpdateComment(
            commentId: _editingCommentId!,
            updateData: updateDto,
            reelId: widget.reelId,
          ),
        );

    _cancelEdit();
    _commentInputController.clear();
  }

  void _startReply(String commentId, String userId, String userName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUserId = userId;
      _replyToUserName = userName;
      _editingCommentId = null;
      _editingCommentContent = null;
    });
    _commentInputController.text = "@$userName ";
    _commentInputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentInputController.text.length),
    );
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToUserId = null;
      _replyToUserName = null;
    });
    if (_editingCommentId == null) {
      _commentInputController.clear();
    }
  }

  void _startEdit(String commentId, String content) {
    setState(() {
      _editingCommentId = commentId;
      _editingCommentContent = content;
      _replyToCommentId = null;
      _replyToUserId = null;
      _replyToUserName = null;
    });
    _commentInputController.text = content;
    _commentInputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentInputController.text.length),
    );
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _editingCommentContent = null;
    });
    if (_replyToCommentId == null) {
      _commentInputController.clear();
    }
  }

  void _handleDelete(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Comment"),
          content: Text("Are you sure you want to delete this comment?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                print("Dispatching DeleteComment: id=$commentId");
                context.read<CommentBloc>().add(
                      DeleteComment(
                          commentId: commentId, reelId: widget.reelId),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingCommentId != null;
    final isReplying = _replyToCommentId != null;

    String inputLabel = 'Add a comment...';
    String? targetName;
    VoidCallback? onCancelAction;

    if (isEditing) {
      inputLabel = 'Edit comment...';
      targetName = "your comment";
      onCancelAction = _cancelEdit;
    } else if (isReplying) {
      inputLabel = 'Add a reply...';
      targetName = _replyToUserName;
      onCancelAction = _cancelReply;
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocSelector<ReelFeedAndActionBloc, ReelFeedAndActionState,
                    int>(
                  selector: (state) {
                    final videoItem = state.videos.firstWhereOrNull(
                      (video) => video.id == widget.reelId,
                    );
                    return videoItem?.commentCount ?? 0;
                  },
                  builder: (context, reelCommentCount) {
                    return Text(
                      '$reelCommentCount Comments',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: widget.onClose),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<CommentBloc, CommentState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  if (state is! CommentInitial && !state.isLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                  }
                  print('Comment Bloc Error: ${state.errorMessage}');
                }
                if (state is CommentLoaded &&
                    state.updatedReelId == widget.reelId &&
                    state.updatedReelCommentCount != null) {
                  debugPrint(
                    'CommentSection Listener: Detected comment count update for reel ${state.updatedReelId} to ${state.updatedReelCommentCount!}',
                  );

                  try {
                    context.read<ReelFeedAndActionBloc>().add(
                          UpdateReelCommentCount(
                            reelId: state.updatedReelId!,
                            newCount: state.updatedReelCommentCount!,
                          ),
                        );
                    debugPrint(
                      'Dispatched UpdateReelCommentCount to ReelFeedAndActionBloc',
                    );
                  } catch (e) {
                    print(
                      'Error dispatching UpdateReelCommentCount: ReelFeedAndActionBloc not found in context: $e',
                    );
                  }
                }
              },
              builder: (context, state) {
                final List<Comment> reelComments = List.of(
                  state.comments.where((c) => c.reelId == widget.reelId),
                );

                final Map<String, CommentTreeData> commentTrees =
                    _buildCommentTrees(reelComments);

                Widget content;

                if (state is CommentInitial ||
                    (state is CommentLoading && state.isInitialLoad)) {
                  content = Center(child: CircularProgressIndicator());
                } else if (state is CommentError && state.isInitialLoad) {
                  content = Center(
                    child: Text(
                      'Error loading comments: ${state.errorMessage ?? "Unknown error"}',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (reelComments.isEmpty) {
                  content = const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                } else {
                  content = SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        CommentList(
                          commentTrees: commentTrees,
                          onStartReply: _startReply,
                          onEdit: _startEdit,
                          onDelete: _handleDelete,
                          currentUserId: widget.currentUserId,
                        ),
                        if (state is CommentLoading && !state.isInitialLoad)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                        if (!state.hasMore &&
                            reelComments.isNotEmpty &&
                            state is! CommentLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'End of comments',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (state is CommentError &&
                            !state.isInitialLoad &&
                            reelComments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Error loading more: ${state.errorMessage ?? "Unknown error"}',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return content;
              },
            ),
          ),
          NewMessage(
            controller: _commentInputController,
            inputLabel: inputLabel,
            targetName: targetName,
            isEditing: isEditing,
            onSend: (text) => _handleSend(text),
            onUpdate: (text) => _handleUpdate(text),
            onCancelAction: onCancelAction,
          ),
        ],
      ),
    );
  }
}

extension ListCommentExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
