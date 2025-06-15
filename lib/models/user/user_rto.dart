class UserRto {
  final String id;
  final String name;
  final String username;
  final String? profilePic;
  final String? bio;
  final int followingCount;
  final int followersCount;
  final int likesCount;

  UserRto({
    required this.id,
    required this.name,
    required this.username,
    this.profilePic,
    this.bio,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
  });

  factory UserRto.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get string values
    String safeString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    // Helper function to safely get int values
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UserRto(
      id: safeString(json['id']),
      name: safeString(json['name']),
      username: safeString(json['username']),
      profilePic: json['profilePic']?.toString(),
      bio: json['bio']?.toString(),
      followingCount: safeInt(json['followingCount']),
      followersCount: safeInt(json['followersCount']),
      likesCount: safeInt(json['likesCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profilePic': profilePic,
      'bio': bio,
      'followingCount': followingCount,
      'followersCount': followersCount,
      'likesCount': likesCount,
    };
  }
} 