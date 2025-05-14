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

  });

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
      };
}
