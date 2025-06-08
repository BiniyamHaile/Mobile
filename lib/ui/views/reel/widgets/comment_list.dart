import 'package:flutter/material.dart';
import 'package:mobile/ui/views/reel/widgets/comment_section.dart';
import 'package:mobile/ui/views/reel/widgets/comments.dart';

class CommentList extends StatelessWidget {
  final String? replyToCommentId;
  final Function(String, String, String) onStartReply;
  final Function(String commentId, String content)
  onEdit; 
  final Function(String commentId) onDelete; 
  final String currentUserId; 
  final Map<String, CommentTreeData> commentTrees;

  const CommentList({
    Key? key,
    this.replyToCommentId, 
    required this.onStartReply,
    required this.onEdit, 
    required this.onDelete, 
    required this.currentUserId, 
    required this.commentTrees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<CommentTreeData> trees = commentTrees.values.toList();

    return Column(
      children:
          trees.map((treeData) {
            return Comments(
              commentList: treeData.replies,
              rootComment: treeData.rootComment,
              replyToCommentId: replyToCommentId, 
              onStartReply: onStartReply,
              onEdit: onEdit, 
              onDelete: onDelete, 
              currentUserId: currentUserId,
            );
          }).toList(),
    );
  }
}
