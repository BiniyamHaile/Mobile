class Profile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profilePic;

  Profile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePic,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      profilePic: json['profilePic'] as String?, // null-safe
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      if (profilePic != null) 'profilePic': profilePic,
    };
  }
}
