import 'dart:io';

import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';
class CreateReelDto {
  CreateReelDto({
    this.videoFile,
    this.description,
    this.isPremiumContent,
    required this.duration,
    this.mentionedUsers,
    this.privacy,
    this.allowComments,
    this.allowSaveToDevice,
    this.saveWithWatermark,
    this.audienceControlUnder18,
  });

  final File? videoFile;
  final String? description;
  final bool? isPremiumContent;
  final int duration;
  final List<MentionedUser>? mentionedUsers;
  final PrivacyOption? privacy;
  final bool? allowComments;
  final bool? allowSaveToDevice;
  final bool? saveWithWatermark;
  final bool? audienceControlUnder18;

  factory CreateReelDto.fromJson(Map<String, dynamic> json) {
    return CreateReelDto(
      videoFile: null,
      description: json['description'] as String?,
      isPremiumContent: json['isPremiumContent'] as bool?,
      duration: json['duration'] as int,
      mentionedUsers: (json['mentionedUsers'] as List<dynamic>?)
          ?.map((e) => MentionedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacy: _stringToReelPrivacy(json['privacy'] as String?),
      allowComments: json['allowComments'] as bool?,
      allowSaveToDevice: json['allowSaveToDevice'] as bool?,
      saveWithWatermark: json['saveWithWatermark'] as bool?,
      audienceControlUnder18: json['audienceControlUnder18'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'isPremiumContent': isPremiumContent,
      'duration': duration,
      'mentionedUsers': mentionedUsers?.map((e) => e.toJson()).toList(),
      'privacy': _reelPrivacyToString(privacy),
      'allowComments': allowComments,
      'allowSaveToDevice': allowSaveToDevice,
      'saveWithWatermark': saveWithWatermark,
      'audienceControlUnder18': audienceControlUnder18,
    };
  }

  static PrivacyOption? _stringToReelPrivacy(String? privacyString) {
    if (privacyString == null) {
      return null;
    }
    switch (privacyString) {
      case 'public':
        return PrivacyOption.public;
      case 'followers':
        return PrivacyOption.followers;
      case 'friends':
        return PrivacyOption.friends;
      case 'only_me':
        return PrivacyOption.onlyYou;
      default:
        return null;
    }
  }

  static String? _reelPrivacyToString(PrivacyOption? privacy) {
    if (privacy == null) {
      return null;
    }
    switch (privacy) {
      case PrivacyOption.public:
        return 'public';
      case PrivacyOption.followers:
        return 'followers';
      case PrivacyOption.friends:
        return 'friends';
      case PrivacyOption.onlyYou:
        return 'only_me';
    }
  }
}