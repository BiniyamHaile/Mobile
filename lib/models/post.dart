class Post {
  final String id;
  final String content;
  final List<String> files;
  final String? authorId;
  final List<String> commentIds;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  

  Post({
    required this.id,
    required this.content,
    required this.files,
    this.authorId,
    required this.commentIds,
    required this.likedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      files: List<String>.from(json['files'] ?? []),
      authorId: json['authorId'],
      commentIds: List<String>.from(json['commentIds'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Post copyWith({
    String? id,
    String? content,
    List<String>? files,
    String? authorId,
    List<String>? commentIds,
    List<String>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      files: files ?? this.files,
      authorId: authorId ?? this.authorId,
      commentIds: commentIds ?? this.commentIds,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FindResult<T> {
  final List<T> data;
  final int total;
  final String? next;
  final String? previous;

  FindResult({
    required this.data,
    required this.total,
    this.next,
    this.previous,
  });

  factory FindResult.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return FindResult<T>(
      data: List<T>.from(json['data'].map((item) => fromJsonT(item))),
      total: json['total'],
      next: json['next'],
      previous: json['previous'],
    );
  }

  FindResult<T> copyWith({
    List<T>? data,
    int? total,
    String? next,
    String? previous,
  }) {
    return FindResult<T>(
      data: data ?? this.data,
      total: total ?? this.total,
      next: next ?? this.next,
      previous: previous ?? this.previous,
    );
  }
}
