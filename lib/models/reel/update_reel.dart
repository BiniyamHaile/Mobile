import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';

class UpdateReelDto {
  UpdateReelDto({
    this.description,
    this.isPremiumContent,
    this.mentionedUsers,
    this.privacy,
    this.allowComments,
    this.allowSaveToDevice,
    this.saveWithWatermark,
    this.audienceControlUnder18,
  });

  final String? description;
  final bool? isPremiumContent;
  final List<MentionedUser>? mentionedUsers;
  final PrivacyOption? privacy;
  final bool? allowComments;
  final bool? allowSaveToDevice;
  final bool? saveWithWatermark;
  final bool? audienceControlUnder18;

  factory UpdateReelDto.fromJson(Map<String, dynamic> json) {
    return UpdateReelDto(
      description: json['description'] as String?,
      isPremiumContent: json['isPremiumContent'] as bool?,
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
    final Map<String, dynamic> json = {};

    if (description != null) {
      json['description'] = description;
    }
    if (isPremiumContent != null) {
      json['isPremiumContent'] = isPremiumContent;
    }
     if (mentionedUsers != null) {
      json['mentionedUsers'] = mentionedUsers?.map((e) => e.toJson()).toList();
    }
    if (privacy != null) {
      json['privacy'] = _reelPrivacyToString(privacy);
    }
    if (allowComments != null) {
      json['allowComments'] = allowComments;
    }
    if (allowSaveToDevice != null) {
      json['allowSaveToDevice'] = allowSaveToDevice;
    }
    if (saveWithWatermark != null) {
      json['saveWithWatermark'] = saveWithWatermark;
    }
    if (audienceControlUnder18 != null) {
      json['audienceControlUnder18'] = audienceControlUnder18;
    }

    return json;
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
