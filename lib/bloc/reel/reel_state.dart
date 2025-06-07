import 'package:equatable/equatable.dart';
import 'package:mobile/models/reel/like/like_status.dart';
import 'package:mobile/models/reel/video_item.dart';

enum ReelActionStatus {
  idle,
  loading,
  postSuccess,
  postFailure,
  updateSuccess,
  updateFailure,
  deleteSuccess,
  deleteFailure,
  interactionSuccess,
  interactionFailure,
  shareSuccess,
  shareFailure,
  reportSuccess,
  reportFailure,
}

class ReelFeedAndActionState extends Equatable {
  const ReelFeedAndActionState({
    this.videos = const [],
    this.isLoadingFeed = false, 
    this.isPaginatingFeed = false, 
    this.hasMoreVideos = true,
    this.feedError = '', 
    this.currentVideoIndex = 0,
    this.preloadedVideoUrls = const {},
    this.likedVideoIds = const <String>{},

    this.actionStatus = ReelActionStatus.idle,
    this.lastActionError = '',
    this.lastAffectedReelId, 
    this.lastInteractionStatus, 
  });

  // --- VideoFeedState properties ---
  final List<VideoItem> videos;
  final bool isLoadingFeed;
  final bool isPaginatingFeed;
  final bool hasMoreVideos;
  final String feedError;
  final int currentVideoIndex;
  final Set<String> preloadedVideoUrls;
  final Set<String> likedVideoIds;

  // --- PostReelState properties/indicators ---
  final ReelActionStatus actionStatus;
  final String lastActionError;
  final String? lastAffectedReelId;
  final LikeStatus? lastInteractionStatus;

  @override
  List<Object?> get props => [
    // --- VideoFeedState properties ---
    videos,
    isLoadingFeed,
    isPaginatingFeed,
    hasMoreVideos,
    feedError,
    currentVideoIndex,
    preloadedVideoUrls,
    likedVideoIds,

    // --- PostReelState properties/indicators ---
    actionStatus,
    lastActionError,
    lastAffectedReelId,
    lastInteractionStatus,
  ];

  ReelFeedAndActionState copyWith({
    // --- VideoFeedState properties ---
    List<VideoItem>? videos,
    bool? isLoadingFeed,
    bool? isPaginatingFeed,
    bool? hasMoreVideos,
    String? feedError,
    int? currentVideoIndex,
    Set<String>? preloadedVideoUrls,
    Set<String>? likedVideoIds,

    // --- PostReelState properties/indicators ---
    ReelActionStatus? actionStatus,
    String? lastActionError,
    String? lastAffectedReelId,
    LikeStatus? lastInteractionStatus,
  }) {
    return ReelFeedAndActionState(
      // --- VideoFeedState properties ---
      videos: videos ?? this.videos,
      isLoadingFeed: isLoadingFeed ?? this.isLoadingFeed,
      isPaginatingFeed: isPaginatingFeed ?? this.isPaginatingFeed,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      feedError: feedError ?? this.feedError,
      currentVideoIndex: currentVideoIndex ?? this.currentVideoIndex,
      preloadedVideoUrls: preloadedVideoUrls ?? this.preloadedVideoUrls,
      likedVideoIds: likedVideoIds ?? this.likedVideoIds,

      // --- PostReelState properties/indicators ---
      actionStatus: actionStatus ?? this.actionStatus,
      lastActionError: lastActionError ?? this.lastActionError,
      lastAffectedReelId: lastAffectedReelId ?? this.lastAffectedReelId,
      lastInteractionStatus:
          lastInteractionStatus ?? this.lastInteractionStatus,
    );
  }

  factory ReelFeedAndActionState.initial() => const ReelFeedAndActionState(
    likedVideoIds: {},
    actionStatus: ReelActionStatus.idle,
  );
}
