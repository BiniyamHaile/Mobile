import 'package:equatable/equatable.dart';

class ShareReelResponseDto extends Equatable {
  final String sharedReelId;

  final int shareCount;

  const ShareReelResponseDto({
    required this.sharedReelId,
    required this.shareCount,
  });

  factory ShareReelResponseDto.fromJson(Map<String, dynamic> json) {
    return ShareReelResponseDto(
      sharedReelId: json['sharedReel'] as String,
      shareCount: json['shareCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharedReel': sharedReelId,
      'shareCount': shareCount,
    };
  }

  @override
  List<Object?> get props => [sharedReelId, shareCount];

  @override
  String toString() {
    return 'ShareReelResponseDto(sharedReelId: $sharedReelId, shareCount: $shareCount)';
  }
}
