import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/like/likeable_type.dart';

class CreateLikeDto extends Equatable {
  final String userId;
  final String targetId;
  final LikeableType onModel;

  const CreateLikeDto({
    required this.userId,
    required this.targetId,
    required this.onModel,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'targetId': targetId,
      'onModel': onModel.value,
    };
  }

  factory CreateLikeDto.fromJson(Map<String, dynamic> json) {
    return CreateLikeDto(
      userId: json['userId'] as String,
      targetId: json['targetId'] as String,
      onModel: json['onModel'], 
    );
  }

  @override
  List<Object?> get props => [userId, targetId, onModel];
}
