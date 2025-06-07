import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/hashtag_suggestion.dart';
import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/user_suggestion.dart';

class PostDetailsState extends Equatable {
  final String descriptionText;
  final int durationInSeconds;
  final String? thumbnailPath;

  // Suggestion State
  final List<HashtagSuggestion> filteredHashtags;
  final List<UserSuggestion> filteredUsers;
  final String activeSuggestionType;

  // Options State
  final PrivacyOption selectedPrivacy;
  final bool allowComments;
  final bool saveToDevice;
  final bool saveWithWatermark;
  final bool audienceControls;

  final List<MentionedUser> mentionedUsers;

  const PostDetailsState({
    required this.descriptionText,
    required this.durationInSeconds,
    this.thumbnailPath,
    required this.filteredHashtags,
    required this.filteredUsers,
    required this.activeSuggestionType,
    required this.selectedPrivacy,
    required this.allowComments,
    required this.saveToDevice,
    required this.saveWithWatermark,
    required this.audienceControls,
    required this.mentionedUsers,
  });

  factory PostDetailsState.initial() {
    return const PostDetailsState(
      descriptionText: '',
      durationInSeconds: 0,
      thumbnailPath: null,
      filteredHashtags: [],
      filteredUsers: [],
      activeSuggestionType: '',
      selectedPrivacy: PrivacyOption.onlyYou,
      allowComments: true,
      saveToDevice: true,
      saveWithWatermark: false,
      audienceControls: false,
      mentionedUsers: [],
    );
  }

  PostDetailsState copyWith({
    String? descriptionText,
    int? durationInSeconds,
    String? thumbnailPath,
    List<HashtagSuggestion>? filteredHashtags,
    List<UserSuggestion>? filteredUsers,
    String? activeSuggestionType,
    PrivacyOption? selectedPrivacy,
    bool? allowComments,
    bool? saveToDevice,
    bool? saveWithWatermark,
    bool? audienceControls,
    List<MentionedUser>? mentionedUsers,
  }) {
    return PostDetailsState(
      descriptionText: descriptionText ?? this.descriptionText,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      filteredHashtags: filteredHashtags ?? this.filteredHashtags,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      activeSuggestionType: activeSuggestionType ?? this.activeSuggestionType,
      selectedPrivacy: selectedPrivacy ?? this.selectedPrivacy,
      allowComments: allowComments ?? this.allowComments,
      saveToDevice: saveToDevice ?? this.saveToDevice,
      saveWithWatermark: saveWithWatermark ?? this.saveWithWatermark,
      audienceControls: audienceControls ?? this.audienceControls,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
    );
  }

  @override
  List<Object?> get props => [
    descriptionText,
    durationInSeconds,
    thumbnailPath,
    filteredHashtags,
    filteredUsers,
    activeSuggestionType,
    selectedPrivacy,
    allowComments,
    saveToDevice,
    saveWithWatermark,
    audienceControls,
    mentionedUsers,
  ];
}