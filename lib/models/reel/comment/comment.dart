import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Comment extends Equatable {
  final String id;
  final String reelId;
  final String authorId;
  final String authorUsername;
  final String content;
  final String avatar;
  final int likes;
  final DateTime createdAt;
  final String? parentId;
  final bool isLiked;
  final int reelCommentCount;

  const Comment({
    required this.id,
    required this.reelId,
    required this.authorId,
    required this.authorUsername,
    required this.content,
    required this.avatar,
    required this.likes,
    required this.createdAt,
    this.parentId,
    required this.isLiked,
    required this.reelCommentCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("Comment JSON received: $json");
      final ownerJson = json['owner'] as Map<String, dynamic>?;

      final bool isLiked = json['isLiked'] as bool? ?? false;

      final int reelCommentCount = json['reelCommentCount'] as int? ?? 0;


      return Comment(
        id:
            json['_id'] as String? ??
            json['id'] as String? ??
            '',
        reelId:
            json['reel'] as String? ??
            json['reelId'] as String? ??
            '',
        authorId:
            ownerJson?['_id'] as String? ??
            ownerJson?['id'] as String? ??
            '',
        authorUsername:
            ownerJson?['username'] as String? ??
            ownerJson?['name'] as String? ??
            'Unknown User',
        content:
            json['text'] as String? ??
            json['content'] as String? ??
            '',
        avatar:
            ownerJson?['avatar'] as String? ??
            ownerJson?['picture'] as String? ??
            '',
        likes: json['likes'] as int? ?? 0,
        createdAt:
            json['createdAt'] != null
                ? DateTime.tryParse(json['createdAt'] as String) ??
                    DateTime.now()
                : DateTime.now(),
        parentId:
            json['parentCommentId'] as String? ??
            json['parentId']
                as String?,
        isLiked: isLiked,
        reelCommentCount: reelCommentCount,
      );
    } catch (e) {
      debugPrint('Error parsing Comment JSON: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      '_id': id,
      'reel': reelId,
      'owner': {'_id': authorId, 'username': authorUsername, 'avatar': avatar},
      'text': content,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
      'reelCommentCount': reelCommentCount,
    };
    if (parentId != null) {
      json['parentCommentId'] = parentId;
    }
    return json;
  }

  Comment copyWith({
    String? id,
    String? reelId,
    String? authorId,
    String? authorUsername,
    String? content,
    String? avatar,
    int? likes,
    DateTime? createdAt,
    String? parentId,
    bool? isLiked,
    int? reelCommentCount,
  }) {
    return Comment(
      id: id ?? this.id,
      reelId: reelId ?? this.reelId,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      content: content ?? this.content,
      avatar: avatar ?? this.avatar,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      isLiked: isLiked ?? this.isLiked,
      reelCommentCount: reelCommentCount ?? this.reelCommentCount,
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, reelId: $reelId, authorId: $authorId, authorUsername: $authorUsername, content: $content, avatar: $avatar, likes: $likes, createdAt: $createdAt, parentId: $parentId, isLiked: $isLiked, reelCommentCount: $reelCommentCount)';
  }

  @override
  List<Object?> get props => [
    id,
    reelId,
    authorId,
    authorUsername,
    content,
    avatar,
    likes,
    createdAt,
    parentId,
    isLiked,
    reelCommentCount,
  ];
}