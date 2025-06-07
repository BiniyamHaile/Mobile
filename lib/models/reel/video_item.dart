import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';

class VideoItem extends Equatable {
  final String id;
  final String username;
  final String description;
  final String walletId;
  final String videoUrl;
  final String profileImageUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isBookmarked;
  final bool isLiked;

  final bool? isPremiumContent;
  final int duration;
  final List<MentionedUser>? mentionedUsers;
  final PrivacyOption? privacy;
  final bool? allowComments;
  final bool? allowSaveToDevice;
  final bool? saveWithWatermark;
  final bool? audienceControlUnder18;

  final DateTime timestamp;

  static const String defaultUsername = 'Daniel';
  static const String defaultProfileImageUrl =
      'https://res.cloudinary.com/dpmykt0af/image/upload/v1744224571/ImageMagic/jwvonkoaqb7f1yjdbl0k.jpg';

  VideoItem({
    required this.id,
    required this.username,
    required this.description,
    required this.walletId,
    required this.videoUrl,
    required this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isBookmarked,
    required this.isLiked,
    required this.timestamp,
    this.isPremiumContent,
    required this.duration,
    this.mentionedUsers,
    this.privacy,
    this.allowComments,
    this.allowSaveToDevice,
    this.saveWithWatermark,
    this.audienceControlUnder18,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    description,
    walletId,
    videoUrl,
    profileImageUrl,
    likeCount,
    commentCount,
    shareCount,
    isBookmarked,
    isLiked,
    timestamp,
    isPremiumContent,
    duration,
    mentionedUsers,
    privacy,
    allowComments,
    allowSaveToDevice,
    saveWithWatermark,
    audienceControlUnder18,
  ];

  factory VideoItem.fromReelRto(Map<String, dynamic> json) {
    String safeString(dynamic value) => value is String ? value : '';
    int safeInt(dynamic value) =>
        value is int ? value : (value is String ? int.tryParse(value) ?? 0 : 0);
    bool safeBool(dynamic value) =>
        value is bool ? value : (value is int ? value != 0 : false);
    DateTime safeDateTime(dynamic value) {
      try {
        if (value is String && value.isNotEmpty) {
          return DateTime.parse(value).toLocal();
        }
      } catch (e) {
        debugPrint('Error parsing date: $value -> $e');
      }
      return DateTime.now();
    }

    final profileJson = json['profile'];
    final String username = safeString(
      profileJson != null && profileJson is Map<String, dynamic>
          ? profileJson['name']
          : defaultUsername,
    );
    final String walletId = safeString(
      profileJson != null && profileJson is Map<String, dynamic>
          ? profileJson['walletId']
          : "",
    );

    final String profileImageUrl = safeString(
      profileJson != null && profileJson is Map<String, dynamic>
          ? profileJson['picture']
          : defaultProfileImageUrl,
    );

    return VideoItem(
      id: safeString(json['id']),
      username: username,
      description: safeString(json['description']),
      videoUrl: safeString(json['videoURL']),
      walletId: walletId,
      profileImageUrl: profileImageUrl,
      likeCount: safeInt(json['likes']),
      commentCount: safeInt(json['comments']),
      shareCount: safeInt(json['shareCount']),
      isBookmarked: false,
      isLiked: safeBool(json['isLikedByUser']),
      timestamp: safeDateTime(json['createdAt']),
      isPremiumContent: json['isPremiumContent'] as bool?,
      duration: safeInt(json['duration']),
      mentionedUsers: (json['mentionedUsers'] as List<dynamic>?)
          ?.map((e) => MentionedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacy: _stringToPrivacyOption(json['privacy'] as String?),
      allowComments: json['allowComments'] as bool?,
      allowSaveToDevice: json['allowSaveToDevice'] as bool?,
      saveWithWatermark: json['saveWithWatermark'] as bool?,
      audienceControlUnder18: json['audienceControlUnder18'] as bool?,
    );
  }

  static PrivacyOption? _stringToPrivacyOption(String? privacyString) {
    if (privacyString == null) {
      return null;
    }

    switch (privacyString.toLowerCase()) {
      case 'public':
        return PrivacyOption.public;
      case 'followers':
        return PrivacyOption.followers;
      case 'friends':
        return PrivacyOption.friends;
      case 'only_me':
      case 'onlyyou':
        return PrivacyOption.onlyYou;
      default:
        debugPrint('Warning: Unknown privacy string received: $privacyString');
        return null;
    }
  }

  VideoItem copyWith({
    String? id,
    String? username,
    String? description,
    String? walletId,
    String? videoUrl,
    String? profileImageUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isBookmarked,
    bool? isLiked,
    DateTime? timestamp,
    bool? isPremiumContent,
    int? duration,
    List<MentionedUser>? mentionedUsers,
    PrivacyOption? privacy,
    bool? allowComments,
    bool? allowSaveToDevice,
    bool? saveWithWatermark,
    bool? audienceControlUnder18,
  }) {
    return VideoItem(
      id: id ?? this.id,
      username: username ?? this.username,
      description: description ?? this.description,
      walletId: walletId ?? this.walletId,
      videoUrl: videoUrl ?? this.videoUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      timestamp: timestamp ?? this.timestamp,
      isPremiumContent: isPremiumContent ?? this.isPremiumContent,
      duration: duration ?? this.duration,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      privacy: privacy ?? this.privacy,
      allowComments: allowComments ?? this.allowComments,
      allowSaveToDevice: allowSaveToDevice ?? this.allowSaveToDevice,
      saveWithWatermark: saveWithWatermark ?? this.saveWithWatermark,
      audienceControlUnder18:
          audienceControlUnder18 ?? this.audienceControlUnder18,
    );
  }
}
