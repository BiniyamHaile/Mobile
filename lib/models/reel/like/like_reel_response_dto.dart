import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/like/like_status.dart';

class LikeReelResponseDto extends Equatable {
  final LikeStatus status;
  final int likeCount;

  const LikeReelResponseDto({
    required this.status,
    required this.likeCount,
  });

  
  factory LikeReelResponseDto.fromJson(Map<String, dynamic> json) {
    final statusString = json['status'] as String?;
    if (statusString == null) {
      throw const FormatException(
        'Missing "status" field in LikeReelResponseDto',
      );
    }

    final likeCountValue = json['likeCount'];
    if (likeCountValue == null) {
      throw const FormatException(
        'Missing "likeCount" field in LikeReelResponseDto',
      );
    }
    
    final int parsedLikeCount;
    if (likeCountValue is int) {
      parsedLikeCount = likeCountValue;
    } else if (likeCountValue is String) {
      parsedLikeCount =
          int.tryParse(likeCountValue) ??
          (throw FormatException(
            'Invalid "likeCount" string format: $likeCountValue',
          ));
    } else {
      throw FormatException(
        'Unexpected "likeCount" type: ${likeCountValue.runtimeType}',
      );
    }

    LikeStatus parsedStatus;
    switch (statusString.toLowerCase()) {
      case 'liked':
        parsedStatus = LikeStatus.liked;
        break;
      case 'unliked':
        parsedStatus = LikeStatus.unliked;
        break;
      default:
        throw FormatException('Unknown status value: $statusString');
    }

    return LikeReelResponseDto(
      status: parsedStatus,
      likeCount: parsedLikeCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status':
          status
              .toString()
              .split('.')
              .last
              .toUpperCase(),
      'likeCount': likeCount,
    };
  }

  @override
  List<Object?> get props => [status, likeCount];
}
