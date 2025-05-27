import 'package:mobile/models/new_user.dart';

class Post {
  final String id;
  final String content;
  final List<String> files;
  final List<String> commentIds;
  final List<String> likedBy;
  final String? authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? mentions; // Added tags field

  final User? owner; // Added owner field
  final String? walletAddress; // Add this field

  Post({
    required this.id,
    required this.content,
    required this.files,
    required this.commentIds,
    required this.likedBy,
    this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.mentions, // Initialize with an empty list
    required this.owner, // Added to constructor
    this.walletAddress,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      files: List<String>.from(json['files'] ?? []),
      commentIds: List<String>.from(json['commentIds'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      authorId: json['authorId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      mentions:
          List<String>.from(json['mentions'] ?? []), // Parse mentions from JSON
      owner: User.fromJson(json['owner']), // Parse owner from JSON
      walletAddress: json['walletAddress'], // Parse wallet address from JSON
    );
  }

  Post copyWith({
    String? id,
    String? content,
    List<String>? files,
    List<String>? commentIds,
    List<String>? likedBy,
    String? authorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? mentions,
    User? owner,
    String? walletAddress,
  }) {
    return Post(
      id: id ?? this.id,
      content: content ?? this.content,
      files: files ?? this.files,
      commentIds: commentIds ?? this.commentIds,
      likedBy: likedBy ?? this.likedBy,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mentions: mentions ?? this.mentions,
      owner: owner ?? this.owner,
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
