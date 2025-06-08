class MentionedUser {
  MentionedUser({
    required this.userId,
    required this.username,
  });

  final String userId;
  final String username;

  factory MentionedUser.fromJson(Map<String, dynamic> json) {
    return MentionedUser(
      userId: json['userId'] as String,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
    };
  }
}