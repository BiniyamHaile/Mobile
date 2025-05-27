import 'package:equatable/equatable.dart'; 

class UserSuggestion extends Equatable {
  final String id; 
  final String name;
  final String username;
  final String imageUrl;

  const UserSuggestion({
    required this.id,
    required this.name,
    required this.username,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, username, imageUrl];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSuggestion &&
          runtimeType == other.runtimeType &&
          id == other.id && 
          name == other.name &&
          username == other.username &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ username.hashCode ^ imageUrl.hashCode; 
}
