import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/like/like_dto.dart';
import 'package:mobile/models/reel/mentioned_user.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/report/report_reason_details_dto.dart';

abstract class ReelFeedAndActionEvent extends Equatable {
  const ReelFeedAndActionEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialVideos extends ReelFeedAndActionEvent {
  const LoadInitialVideos();
}

class LoadMoreVideos extends ReelFeedAndActionEvent {
  const LoadMoreVideos();
}

class VideoPageChanged extends ReelFeedAndActionEvent {
  const VideoPageChanged(this.newIndex);

  final int newIndex;

  @override
  List<Object?> get props => [newIndex];
}

class MarkMoreVideosAvailable extends ReelFeedAndActionEvent {
  const MarkMoreVideosAvailable();
}


class PostReel extends ReelFeedAndActionEvent {
  final String videoPath;
  final String? description;
  final int duration;
  final bool? isPremiumContent;
  final List<MentionedUser>? mentionedUsers;
  final PrivacyOption selectedPrivacy;
  final bool? allowComments;
  final bool? allowSaveToDevice;
  final bool? saveWithWatermark;
  final bool? audienceControlUnder18;

  const PostReel({
    required this.videoPath,
    this.description,
    required this.duration,
    this.isPremiumContent = false,
    this.mentionedUsers,
    required this.selectedPrivacy,
    this.allowComments = true,
    this.allowSaveToDevice = true,
    this.saveWithWatermark = false,
    this.audienceControlUnder18 = false,
  });

  @override
  List<Object?> get props => [
    videoPath,
    description,
    duration,
    isPremiumContent,
    mentionedUsers,
    selectedPrivacy,
    allowComments,
    allowSaveToDevice,
    saveWithWatermark,
    audienceControlUnder18,
  ];
}

class UpdateReel extends ReelFeedAndActionEvent {
  final String reelId;
  final String? description;
  final bool? isPremiumContent;
  final List<MentionedUser>? mentionedUsers;
  final PrivacyOption? privacy;
  final bool? allowComments;
  final bool? allowSaveToDevice;
  final bool? saveWithWatermark;
  final bool? audienceControlUnder18;

  const UpdateReel({
    required this.reelId,
    this.description,
    this.isPremiumContent,
    this.mentionedUsers,
    this.privacy,
    this.allowComments,
    this.allowSaveToDevice,
    this.saveWithWatermark,
    this.audienceControlUnder18,
  });

  @override
  List<Object?> get props => [
    reelId,
    description,
    isPremiumContent,
    mentionedUsers,
    privacy,
    allowComments,
    allowSaveToDevice,
    saveWithWatermark,
    audienceControlUnder18,
  ];
}

class DeleteReel extends ReelFeedAndActionEvent {
  final String reelId;

  const DeleteReel({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

class LikeReel extends ReelFeedAndActionEvent {
  final CreateLikeDto likeData;

  const LikeReel({required this.likeData});

  @override
  List<Object?> get props => [likeData];
}

class ShareReel extends ReelFeedAndActionEvent {
  final String reelId;

  const ShareReel({required this.reelId});

  @override
  List<Object?> get props => [reelId];
}

class ReportReel extends ReelFeedAndActionEvent {
  final String reelId;
  final ReportReasonDetailsDto reasonDetails;

  const ReportReel({required this.reelId, required this.reasonDetails});

  @override
  List<Object?> get props => [reelId, reasonDetails];
}

class UpdateReelCommentCount extends ReelFeedAndActionEvent {
  final String reelId;
  final int newCount;
  const UpdateReelCommentCount({required this.reelId, required this.newCount});

  @override
  List<Object> get props => [reelId, newCount];
}