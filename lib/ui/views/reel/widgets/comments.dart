import 'package:comment_tree/comment_tree.dart' as ct;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/comment/comment_bloc.dart';
import 'package:mobile/bloc/comment/comment_event.dart';
import 'package:mobile/models/reel/comment/comment.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/like/likeable_type.dart';

class Comments extends StatefulWidget {
  final List<Comment> commentList;
  final String? replyToCommentId;
  final Function(String, String, String) onStartReply;
  final Function(String commentId, String content) onEdit;
  final Function(String commentId) onDelete;
  final String currentUserId;
  final Comment rootComment;

  const Comments({
    Key? key,
    required this.commentList,
    required this.onStartReply,
    required this.onEdit,
    required this.onDelete,
    required this.currentUserId,
    this.replyToCommentId,
    required this.rootComment,
  }) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  Widget _buildCommentContent(BuildContext context, Comment commentData) {
    final isAuthor = commentData.authorId == widget.currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commentData.authorUsername,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commentData.content,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (isAuthor)
              PopupMenuButton<String>(
                onSelected: (String item) {
                  if (item == 'edit') {
                    widget.onEdit(commentData.id, commentData.content);
                  } else if (item == 'delete') {
                    widget.onDelete(commentData.id);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert, size: 18, color: Colors.grey[700]),
                padding: EdgeInsets.zero,
                elevation: 8.0,
              ),
          ],
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text('time ago'),
                    const SizedBox(width: 24),
                    if (commentData.reelId == widget.rootComment.reelId)
                      GestureDetector(
                        onTap: () => widget.onStartReply(
                          commentData.id,
                          commentData.authorUsername,
                          commentData.authorUsername,
                        ),
                        child: const Text('Reply'),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    final commentBloc = context.read<CommentBloc>();
                    final likeData = CreateLikeDto(
                      userId: widget.currentUserId,
                      targetId: commentData.id,
                      onModel: LikeableType.comment,
                    );
                    commentBloc.add(
                      LikeComment(likeData: likeData),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        commentData.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color:
                            commentData.isLiked ? Colors.red : Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${commentData.likes}',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: ct.CommentTreeWidget<Comment, Comment>(
        widget.rootComment,
        widget.commentList,
        treeThemeData: const ct.TreeThemeData(
          lineColor: Colors.blue,
          lineWidth: 1.5,
        ),
        avatarRoot: (context, data) => PreferredSize(
          preferredSize: Size.fromRadius(18),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(
              data.avatar,
            ),
          ),
        ),
        avatarChild: (context, data) => PreferredSize(
          preferredSize: const Size.fromRadius(12),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(
              data.avatar,
            ),
          ),
        ),
        contentChild: (context, data) => _buildCommentContent(context, data),
        contentRoot: (context, data) => _buildCommentContent(context, data),
      ),
    );
  }
}
