class UpdateCommentDto {
  final String content;

  UpdateCommentDto({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  @override
  String toString() {
    return 'UpdateCommentDto(text: "$content")';
  }
}
