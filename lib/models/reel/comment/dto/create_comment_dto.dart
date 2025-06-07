class CreateCommentDto {
  final String reelId;
  final String content;
  final String?
      parentCommentId;

  CreateCommentDto({
    required this.reelId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'reelId': reelId,
      'content': content,
    };

    if (parentCommentId != null) {
      json['parentCommentId'] =
          parentCommentId;
    }
    return json;
  }

  @override
  String toString() {
    return 'CreateCommentDto(reelId: $reelId, content: "$content", parentCommentId: $parentCommentId)';
  }
}
