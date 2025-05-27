
import 'package:mobile/models/new_user.dart';

class Comment {
  final String id;
  final String content;
  final String postId;
  final List<String> replies;
  final List<String> likedBy;
  final List<String> files;
  final List<String> mentions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final String? authorId;
  final User? owner;

  late List<Comment> commentRepliesList = [];

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.replies,
    required this.likedBy,
    required this.files,
    required this.mentions,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.authorId,
    this.commentRepliesList = const [],
    this.owner,

  });


  bool isLikedByUser(String userId) => likedBy.contains(userId);

  Comment copyWith({
    String? id,
    String? content,
    String? postId,
    List<String>? replies,
    List<String>? likedBy,
    List<String>? files,
    List<String>? mentions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    String? authorId,
    User? owner,
    List<Comment>? commentRepliesList,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      postId: postId ?? this.postId,
      replies: replies ?? this.replies,
      likedBy: likedBy ?? this.likedBy,
      files: files ?? this.files,
      mentions: mentions ?? this.mentions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      authorId: authorId ?? this.authorId,
      owner: owner ?? this.owner,
      commentRepliesList: commentRepliesList ?? this.commentRepliesList,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    print('Comment.fromJson: $json');
  
    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      replies: List<String>.from(json['replies'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      files: List<String>.from(json['files'] ?? []),
      mentions: List<String>.from(json['mentions'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      parentId: json['parentId'],
      authorId: json['authorId'],
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
     
          
    );
  }

  int get likeCount => likedBy.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'postId': postId,
        'replies': replies,
        'likedBy': likedBy,
        'files': files,
        'mentions': mentions,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'parentId': parentId,
        'authorId': authorId,
        'owner': owner?.toJson(),};

}


