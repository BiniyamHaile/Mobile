import 'package:equatable/equatable.dart';

class DeleteCommentResponseDto extends Equatable {
  final String deletedCommentReelId;

  final int newReelCommentCount;

  const DeleteCommentResponseDto({
    required this.deletedCommentReelId,
    required this.newReelCommentCount,
  });

  factory DeleteCommentResponseDto.fromJson(Map<String, dynamic> json) {
    return DeleteCommentResponseDto(
      deletedCommentReelId: json['deletedCommentReelId'] as String,
      newReelCommentCount: json['newReelCommentCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deletedCommentReelId': deletedCommentReelId,
      'newReelCommentCount': newReelCommentCount,
    };
  }

  @override
  List<Object?> get props => [
    deletedCommentReelId,
    newReelCommentCount,
  ];

  @override
  String toString() {
    return 'DeleteCommentResponseDto(deletedCommentReelId: $deletedCommentReelId, newReelCommentCount: $newReelCommentCount)';
  }
}