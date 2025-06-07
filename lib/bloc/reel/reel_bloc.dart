import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/like/like_status.dart';
import 'package:mobile/models/reel/reel.dart';
import 'package:mobile/models/reel/report/create_report_dto.dart';
import 'package:mobile/models/reel/report/reported_entity_type.dart';
import 'package:mobile/models/reel/share_reel_response_dto.dart';
import 'package:mobile/models/reel/update_reel.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/services/api/reel/reel_repository.dart';
import 'package:mobile/services/api/reel_feed/reel_feed_repository.dart';

class ReelFeedAndActionBloc
    extends Bloc<ReelFeedAndActionEvent, ReelFeedAndActionState> {
  ReelFeedAndActionBloc(
    this.videoFeedRepository,
    this.reelActionRepository,
  ) : super(ReelFeedAndActionState.initial()) {
    on<LoadInitialVideos>(_onLoadInitialVideos);
    on<LoadMoreVideos>(_onLoadMoreVideos);
    on<VideoPageChanged>(_onVideoPageChanged);
    on<MarkMoreVideosAvailable>(_onMarkMoreVideosAvailable);

    on<PostReel>(_onPostReel);
    on<UpdateReel>(_onUpdateReel);
    on<DeleteReel>(_onDeleteReel);
    on<LikeReel>(
      _onLikeReel,
    ); 
    on<ShareReel>(_onShareReel);
    on<ReportReel>(_onReportReel);

    on<UpdateReelCommentCount>(_onReelCommentCountUpdated);

    add(const LoadInitialVideos());
  }

  final VideoFeedRepository videoFeedRepository;
  final ReelRepository
  reelActionRepository; 
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};

  Future<void> _onLoadInitialVideos(
    LoadInitialVideos event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    if (state.isLoadingFeed || state.videos.isNotEmpty) return;

    emit(
      state.copyWith(isLoadingFeed: true, feedError: ''),
    ); 

    try {
      final List<VideoItem> videos = await videoFeedRepository.fetchVideos();

      final Set<String> likedIdsFromInitialLoad =
          videos
              .where(
                (video) => video.isLiked,
              ) 
              .map((video) => video.id) 
              .toSet(); 
              
      final bool hasMoreVideos = videos.isNotEmpty; 

      emit(
        state.copyWith(
          isLoadingFeed: false,
          videos: videos,
          hasMoreVideos: hasMoreVideos,
          currentVideoIndex: 0,
          feedError: '', 
          likedVideoIds: likedIdsFromInitialLoad,
        ),
      );

      if (videos.isNotEmpty) {
        _preloadNextVideos();
      }
    } catch (e) {
      debugPrint('Error loading initial videos: $e');
      emit(state.copyWith(isLoadingFeed: false, feedError: e.toString()));
    }
  }

  Future<void> _onLoadMoreVideos(
    LoadMoreVideos event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    if (state.isPaginatingFeed || !state.hasMoreVideos) {
      debugPrint(
        "Load more ignored: isPaginatingFeed=${state.isPaginatingFeed}, hasMore=${state.hasMoreVideos}",
      );
      return;
    }

    emit(
      state.copyWith(isPaginatingFeed: true, feedError: ''),
    ); 

    try {
      if (state.videos.isEmpty) {
        debugPrint("Attempted to load more but videos list is empty.");
        emit(state.copyWith(isPaginatingFeed: false)); 
        return;
      }

      final lastVideoCreatedAt = state.videos.last.timestamp;
      final List<VideoItem> moreVideos = await videoFeedRepository
          .fetchMoreVideos(lastVideoCreatedAt: lastVideoCreatedAt);

      final Set<String> likedIdsFromMoreLoad =
          moreVideos
              .where(
                (video) => video.isLiked,
              ) 
              .map((video) => video.id) 
              .toSet(); 
      print("likedIdsFromMoreLoad $likedIdsFromMoreLoad");
      final Set<String> updatedLikedIds = Set<String>.from(state.likedVideoIds)
        ..addAll(likedIdsFromMoreLoad);
      final bool hasMoreVideos =
          moreVideos.isNotEmpty; 

      final List<VideoItem> updatedVideos = List<VideoItem>.from(state.videos)
        ..addAll(moreVideos);

      emit(
        state.copyWith(
          videos: updatedVideos,
          isPaginatingFeed: false,
          hasMoreVideos: hasMoreVideos,
          feedError: '', 
          likedVideoIds: updatedLikedIds,
        ),
      );

      if (moreVideos.isNotEmpty) {
        _preloadNextVideos();
      }
    } catch (e) {
      debugPrint('Error loading more videos: $e');
      emit(state.copyWith(isPaginatingFeed: false, feedError: e.toString()));
    }
  }

  Future<void> _onVideoPageChanged(
    VideoPageChanged event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    final newIndex = event.newIndex;

    if (newIndex == state.currentVideoIndex) return;

    emit(state.copyWith(currentVideoIndex: newIndex));

    _preloadNextVideos();

    if (state.hasMoreVideos &&
        !state.isPaginatingFeed &&
        newIndex >= state.videos.length - 2) {
      debugPrint("Triggering LoadMoreVideos from page change.");
      add(const LoadMoreVideos());
    }
  }

  void _onMarkMoreVideosAvailable(
    MarkMoreVideosAvailable event,
    Emitter<ReelFeedAndActionState> emit,
  ) {
    if (!state.hasMoreVideos) {
      debugPrint('Marking hasMoreVideos as true.');
      emit(state.copyWith(hasMoreVideos: true));
    } else {
      debugPrint('hasMoreVideos is already true, no state change needed.');
    }
  }

  void _preloadNextVideos() {
    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;
    final videosToConsider = state.videos
        .skip(currentIndex + 1) 
        .take(2); 

    for (final videoItem in videosToConsider) {
      final videoUrl = videoItem.videoUrl;
      if (!_preloadQueue.contains(videoUrl) &&
          !_preloadedFiles.containsKey(videoUrl)) {
        debugPrint('Adding $videoUrl to preload queue.');
        _preloadQueue.add(videoUrl);
        _preloadVideo(videoUrl);
      } else {
        debugPrint('$videoUrl already preloaded or in queue.');
      }
    }
  }

  Future<void> _preloadVideo(String videoUrl) async {
    try {
      debugPrint('Attempting to preload $videoUrl...');
      final file = await getCachedVideoFile(videoUrl);
      _preloadedFiles[videoUrl] = file;

      final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
        ..add(videoUrl);

      emit(state.copyWith(preloadedVideoUrls: currentPreloaded));

      debugPrint('Successfully preloaded $videoUrl');
    } catch (e) {
      debugPrint('Error preloading video $videoUrl: $e');
    } finally {
      if (_preloadQueue.contains(videoUrl)) {
        _preloadQueue.remove(videoUrl);
      }
    }
  }

  Future<File> getCachedVideoFile(String videoUrl) async {
    if (_preloadedFiles.containsKey(videoUrl)) {
      debugPrint('Serving $videoUrl from internal cache map.');
      return _preloadedFiles[videoUrl]!;
    }

    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(videoUrl);

    if (fileInfo != null) {
      debugPrint('Serving $videoUrl from flutter_cache_manager.');
      _preloadedFiles[videoUrl] = fileInfo.file;
      return fileInfo.file;
    } else {
      debugPrint('Downloading $videoUrl...');
      final file = await cacheManager.getSingleFile(videoUrl);
      debugPrint('Downloaded $videoUrl.');
      _preloadedFiles[videoUrl] = file;
      return file;
    }
  }

  Future<void> _onPostReel(
    PostReel event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ReelActionStatus.loading,
        lastActionError: '',
      ),
    );

    try {
      final createReelDto = CreateReelDto(
        description: event.description,
        duration: event.duration,
        isPremiumContent: event.isPremiumContent,
        mentionedUsers: event.mentionedUsers,
        privacy: event.selectedPrivacy,
        allowComments: event.allowComments,
        allowSaveToDevice: event.allowSaveToDevice,
        saveWithWatermark: event.saveWithWatermark,
        audienceControlUnder18: event.audienceControlUnder18,
      );

      await reelActionRepository.postReel(
        videoFilePath: event.videoPath,
        reelData: createReelDto,
      );

      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.postSuccess,
          lastAffectedReelId: null,
        ),
      ); 
    } catch (e) {
      debugPrint('Error during PostReel operation: $e');
      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.postFailure,
          lastActionError: e.toString(),
          lastAffectedReelId: null,
        ),
      );
    } finally {
    }
  }

  Future<void> _onUpdateReel(
    UpdateReel event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ReelActionStatus.loading,
        lastActionError: '',
        lastAffectedReelId: event.reelId,
      ),
    );

    try {
      final updateReelDto = UpdateReelDto(
        description: event.description,
        isPremiumContent: event.isPremiumContent,
        mentionedUsers: event.mentionedUsers,
        privacy: event.privacy,
        allowComments: event.allowComments,
        allowSaveToDevice: event.allowSaveToDevice,
        saveWithWatermark: event.saveWithWatermark,
        audienceControlUnder18: event.audienceControlUnder18,
      );

      await reelActionRepository.updateReel(
        reelId: event.reelId,
        updateData: updateReelDto,
      );

      final updatedVideos =
          state.videos.map((video) {
            if (video.id == event.reelId) {
              return video.copyWith(
                description: event.description,
                isPremiumContent: event.isPremiumContent,
                mentionedUsers: event.mentionedUsers,
                privacy: event.privacy,
                allowComments: event.allowComments,
                allowSaveToDevice: event.allowSaveToDevice,
                saveWithWatermark: event.saveWithWatermark,
                audienceControlUnder18: event.audienceControlUnder18,
              );
            }
            return video; 
          }).toList();

      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.updateSuccess,
          lastActionError: '',
          lastAffectedReelId: event.reelId,
          videos: updatedVideos, 
          lastInteractionStatus: null, 
        ),
      );
    } catch (e) {
      debugPrint('Error during UpdateReel operation: $e');
      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.updateFailure,
          lastActionError: e.toString(),
          lastAffectedReelId: event.reelId,
          lastInteractionStatus: null,
        ),
      );
    }
  }

  Future<void> _onDeleteReel(
    DeleteReel event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ReelActionStatus.loading,
        lastActionError: '',
        lastAffectedReelId: event.reelId,
      ),
    );

    try {
      await reelActionRepository.deleteReel(reelId: event.reelId);

      debugPrint('Reel deleted successfully for reel ID ${event.reelId}.');

      final updatedVideos =
          state.videos.where((video) => video.id != event.reelId).toList();
      final newCurrentIndex = state.currentVideoIndex.clamp(
        0,
        updatedVideos.length > 0 ? updatedVideos.length - 1 : 0,
      );

      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.deleteSuccess,
          lastActionError: '',
          lastAffectedReelId: event.reelId,
          videos: updatedVideos,
          currentVideoIndex: newCurrentIndex,
          lastInteractionStatus: null, 
        ),
      );

      _preloadNextVideos();
    } catch (e) {
      debugPrint(
        'Error during DeleteReel operation for reel ID ${event.reelId}: $e',
      );
      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.deleteFailure,
          lastActionError: e.toString(),
          lastAffectedReelId: event.reelId,
          lastInteractionStatus: null,
        ),
      );
    }
  }

  Future<void> _onLikeReel(
    LikeReel event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    final reelId = event.likeData.targetId;

    final Set<String> optimisticLikedIds = Set<String>.from(
      state.likedVideoIds,
    );
    final bool isCurrentlyLikedBeforeApi = optimisticLikedIds.contains(
      reelId,
    ); 
    if (isCurrentlyLikedBeforeApi) {
      optimisticLikedIds.remove(reelId);
    } else {
      optimisticLikedIds.add(reelId);
    }

    emit(
      state.copyWith(
        likedVideoIds: optimisticLikedIds, 
        actionStatus: ReelActionStatus.loading,
        lastAffectedReelId: reelId,
        lastActionError: '',
        lastInteractionStatus: null,
      ),
    );

    try {
      final response = await reelActionRepository.like(
        likeData: event.likeData,
      );

      debugPrint(
        'Reel like/unlike operation successful for $reelId. Status: ${response.status}, New Count: ${response.likeCount}', // Log the new count from API
      );

      final bool isLikedFinal = (response.status == LikeStatus.liked);

      final Set<String> finalLikedIds = Set<String>.from(
        state.likedVideoIds,
      ); 
      if (isLikedFinal) {
        finalLikedIds.add(reelId); 
      } else {
        finalLikedIds.remove(
          reelId,
        ); 
      }

      final List<VideoItem> updatedVideos =
          state.videos.map((video) {
            if (video.id == reelId) {
              debugPrint(
                'Updating like count for ${video.id} with API value: ${video.likeCount} -> ${response.likeCount}',
              );
              return video.copyWith(
                likeCount:
                    response
                        .likeCount, 
                isLiked:
                    isLikedFinal, 
              );
            }
            return video; 
          }).toList();

      emit(
        state.copyWith(
          videos:
              updatedVideos,
          likedVideoIds: finalLikedIds, 
          actionStatus:
              ReelActionStatus.interactionSuccess,
          lastAffectedReelId: reelId,
          lastInteractionStatus: response.status,
          lastActionError: '', 
        ),
      );
    } catch (e) {
      debugPrint('Error during LikeReel operation for reel ID $reelId: $e');

      final Set<String> revertedLikedIds = Set<String>.from(
        state.likedVideoIds,
      ); 
      if (!isCurrentlyLikedBeforeApi) {
        revertedLikedIds.remove(
          reelId,
        ); 
      } else {
        revertedLikedIds.add(
          reelId,
        ); 
      }

      emit(
        state.copyWith(
          
          likedVideoIds: revertedLikedIds, 
          actionStatus:
              ReelActionStatus.interactionFailure,
          lastAffectedReelId: reelId,
          lastActionError: e.toString(),
          lastInteractionStatus: null, 
        ),
      );
    }

  }

  Future<void> _onShareReel(
    ShareReel event, 
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    final reelId = event.reelId; 

    emit(
      state.copyWith(
        actionStatus: ReelActionStatus.loading,
        lastActionError: '',
        lastAffectedReelId: reelId,
        lastInteractionStatus: null, 
      ),
    );

    try {
      final ShareReelResponseDto response = await reelActionRepository
          .shareReel(reelId: reelId);

      debugPrint(
        'Reel share operation successful for reel ID ${response.sharedReelId}. New Share Count: ${response.shareCount}',
      );

      final List<VideoItem> updatedVideos =
          state.videos.map((video) {
            if (video.id == response.sharedReelId) {
              return video.copyWith(
                shareCount:
                    response
                        .shareCount, 
              );
            }
            return video; 
          }).toList();

      emit(
        state.copyWith(
          actionStatus:
              ReelActionStatus.shareSuccess, 
          lastActionError: '',
          lastAffectedReelId:
              response.sharedReelId, 
          videos:
              updatedVideos, 
          lastInteractionStatus:
              null, 
        ),
      );
    } catch (e) {
      debugPrint(
        'Error during ShareReel operation for reel ID $reelId: $e', 
      );
      emit(
        state.copyWith(
          actionStatus:
              ReelActionStatus.shareFailure, 
          lastActionError: e.toString(),
          lastAffectedReelId:
              reelId, 
          lastInteractionStatus:
              null, 
        ),
      );
    }
  }

  Future<void> _onReportReel(
    ReportReel event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: ReelActionStatus.loading,
        lastActionError: '',
        lastAffectedReelId: event.reelId,
      ),
    );

    try {
      final createReportDto = CreateReportDto(
        reasonDetails: event.reasonDetails,
        reportedEntityId: event.reelId,
        reportedEntityType: ReportedEntityType.reel,
      );

      await reelActionRepository.reportReel(reportData: createReportDto);

      debugPrint('Reel reported successfully for reel ID ${event.reelId}.');

      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.reportSuccess,
          lastActionError: '',
          lastAffectedReelId: event.reelId,
          lastInteractionStatus: null,
        ),
      );
    } catch (e) {
      debugPrint(
        'Error during ReportReel operation for reel ID ${event.reelId}: $e',
      );
      emit(
        state.copyWith(
          actionStatus: ReelActionStatus.reportFailure,
          lastActionError: e.toString(),
          lastAffectedReelId: event.reelId,
          lastInteractionStatus: null,
        ),
      );
    }
  }

  Future<void> _onReelCommentCountUpdated(
    UpdateReelCommentCount event,
    Emitter<ReelFeedAndActionState> emit,
  ) async {
    final reelIndex = state.videos.indexWhere(
      (video) => video.id == event.reelId,
    );

    if (reelIndex != -1) {
      final updatedVideos = List<VideoItem>.from(state.videos);
      final oldVideo = updatedVideos[reelIndex];

      final updatedVideo = oldVideo.copyWith(commentCount: event.newCount);

      updatedVideos[reelIndex] = updatedVideo;

      debugPrint(
        'Reel ${event.reelId}: Updating comment count in feed list to ${event.newCount}',
      );

      emit(state.copyWith(videos: updatedVideos));
    } else {
      debugPrint(
        'Reel ${event.reelId} not found in current feed list. Cannot update comment count locally.',
      );
 
    }
  }

  @override
  Future<void> close() {
    _preloadQueue.clear();
    _preloadedFiles.clear();
    debugPrint('ReelFeedAndActionBloc closed. Preload resources cleared.');
    return super.close();
  }
}
