import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/user_suggestion.dart';
import 'package:uuid/uuid.dart';

bool isWhitespace(String s) {
  return s == ' ' || s == '\n' || s == '\r' || s == '\t';
}

final _uuid = const Uuid();

abstract class PostDetailsEvent extends Equatable {
  const PostDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialDetails extends PostDetailsEvent {
  final String? videoPath;
  final String? initialDescription;
  final PrivacyOption? initialPrivacy;
  final bool? initialAllowComments;
  final bool? initialSaveToDevice;
  final bool? initialSaveWithWatermark;
  final bool? initialAudienceControls;
  final String? videoUrlForThumbnail;

  const LoadInitialDetails({
    this.videoPath,
    this.initialDescription,
    this.initialPrivacy,
    this.initialAllowComments,
    this.initialSaveToDevice,
    this.initialSaveWithWatermark,
    this.initialAudienceControls,
    this.videoUrlForThumbnail,
  });

  @override
  List<Object?> get props => [
    videoPath,
    initialDescription,
    initialPrivacy,
    initialAllowComments,
    initialSaveToDevice,
    initialSaveWithWatermark,
    initialAudienceControls,
    videoUrlForThumbnail,
  ];
}

class DescriptionChanged extends PostDetailsEvent {
  final String text;
  final TextSelection selection;
  const DescriptionChanged(this.text, this.selection);
  @override
  List<Object?> get props => [text, selection];
}

class SuggestionSelected extends PostDetailsEvent {
  final String textToInsert;
  final UserSuggestion? userSuggestion;
  const SuggestionSelected(this.textToInsert, {this.userSuggestion});
   @override
  List<Object?> get props => [textToInsert, userSuggestion];
}

class HideSuggestions extends PostDetailsEvent {
  const HideSuggestions({required this.suggestionType});

  final String suggestionType;

  @override
  List<Object?> get props => [suggestionType];

  @override
  String toString() {
    return 'HideSuggestions { suggestionType: $suggestionType }';
  }
}

class UpdatePrivacyOption extends PostDetailsEvent {
  final PrivacyOption privacy;
  const UpdatePrivacyOption(this.privacy);
   @override
  List<Object?> get props => [privacy];
}

class UpdateAllowCommentsOption extends PostDetailsEvent {
  final bool allowed;
  const UpdateAllowCommentsOption(this.allowed);
   @override
  List<Object?> get props => [allowed];
}

class UpdateSaveToDeviceOption extends PostDetailsEvent {
  final bool save;
  const UpdateSaveToDeviceOption(this.save);
   @override
  List<Object?> get props => [save];
}

class UpdateSaveWithWatermarkOption extends PostDetailsEvent {
  final bool withWatermark;
  const UpdateSaveWithWatermarkOption(this.withWatermark);
   @override
  List<Object?> get props => [withWatermark];
}

class UpdateAudienceControlsOption extends PostDetailsEvent {
  final bool controlsEnabled;
  const UpdateAudienceControlsOption(this.controlsEnabled);
   @override
  List<Object?> get props => [controlsEnabled];
}
