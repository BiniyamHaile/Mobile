class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? password;
  final String? role;
  final String? walletAddress;
  final String? username;
  final String? bio;
  final String? profilePic;
  final List<String>? following;
  final List<String>? followers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.password,
    this.role,
    this.walletAddress,
    this.username,
    this.bio,
    this.profilePic,
    this.following,
    this.followers,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      password: json['password'],
      role: json['role'],
      walletAddress: json['walletAddress'],
      username: json['username'],
      bio: json['bio'],
      profilePic: json['profilePic'],
      following: (json['following'] as List?)?.map((e) => e.toString()).toList(),
      followers: (json['followers'] as List?)?.map((e) => e.toString()).toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'role': role,
      'walletAddress': walletAddress,
      'username': username,
      'bio': bio,
      'profilePic': profilePic,
      'following': following,
      'followers': followers,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
