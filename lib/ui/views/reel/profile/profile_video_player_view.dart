import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/views/reel/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ProfileVideoPlayerView extends StatefulWidget {
  const ProfileVideoPlayerView({
    Key? key,
    required this.userVideos,
    required this.initialIndex,
  }) : super(key: key);

  final List<VideoItem> userVideos;
  final int initialIndex;

  @override
  State<ProfileVideoPlayerView> createState() => _ProfileVideoPlayerViewState();
}

class _ProfileVideoPlayerViewState extends State<ProfileVideoPlayerView>
    with WidgetsBindingObserver {
  final int _maxCacheSize = 3;

  late final PreloadPageController _pageController;

  bool _isAppActive = true;

  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = Set<String>();

  late int _currentPage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _currentPage = widget.initialIndex.clamp(0, widget.userVideos.length - 1);

    _pageController = PreloadPageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeVideo(_currentPage);
      await _manageControllerWindow(_currentPage);
    });
    _loadUserId();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      _pauseAllControllers();
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (widget.userVideos.isEmpty || index >= widget.userVideos.length) return;

    final video = widget.userVideos[index];
    final controller = await _getOrCreateController(
      video,
    );

    if (controller != null) {
      await _playController(video.id);
    }
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (widget.userVideos.isEmpty || _currentPage >= widget.userVideos.length)
      return;

    await _pauseAllControllers();

    final currentVideoId = widget.userVideos[_currentPage].id;
    final controller = _getController(currentVideoId);

    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      debugPrint(
        'ProfileVideoPlayer: Reinitializing controller for $currentVideoId due to error/uninitialized state',
      );
      await _removeController(currentVideoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _initializeVideo(_currentPage);

    await _manageControllerWindow(_currentPage);
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      print('Fetched SharedPreferences userId in VideoFeedView: $userId');

      if (mounted) {
        setState(() {
          _currentUserId = userId;
        });
      }
    } catch (e) {
      debugPrint(
          'Error fetching userId from SharedPreferences in VideoFeedView: $e');
      if (mounted) {
        setState(() {
          _currentUserId = null;
        });
      }
    }
  }

  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  Future<VideoPlayerController?> _getOrCreateController(VideoItem video) async {
    if (_controllerCache.containsKey(video.id) &&
        !_disposingControllers.contains(video.id)) {
      _touchController(video.id);
      return _controllerCache[video.id];
    }

    if (_disposingControllers.contains(video.id)) {
      debugPrint(
        'ProfileVideoPlayer: Controller for ${video.id} is currently being disposed. Skipping creation.',
      );
      return null;
    }

    try {
      final videoFile =
          await context.read<ReelFeedAndActionBloc>().getCachedVideoFile(
                video.videoUrl,
              );

      final controller = VideoPlayerController.file(videoFile!);

      await controller.initialize();

      controller.setLooping(true);

      _controllerCache[video.id] = controller;
      _touchController(video.id);

      _enforceCacheLimit();

      return controller;
    } catch (e) {
      debugPrint(
        'ProfileVideoPlayer: Error initializing controller for ${video.id}: $e',
      );
      _controllerCache.remove(video.id);
      _accessOrder.remove(video.id);
      return null;
    }
  }

  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      try {
        if (_currentPage < widget.userVideos.length &&
            widget.userVideos[_currentPage].id == videoId) {
          await controller.seekTo(Duration.zero);
        }

        await controller.play();
        debugPrint('ProfileVideoPlayer: Played video: $videoId');
      } catch (e) {
        debugPrint('ProfileVideoPlayer: Error playing video $videoId: $e');
      }
    } else if (controller != null && !controller.value.isInitialized) {
      debugPrint(
        'ProfileVideoPlayer: Controller for $videoId not initialized, cannot play.',
      );
    }
  }

  Future<void> _pauseAllControllers() async {
    debugPrint('ProfileVideoPlayer: Pausing all controllers...');
    final controllers = List<VideoPlayerController>.from(
      _controllerCache.values,
    );
    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized) {
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('ProfileVideoPlayer: Error pausing controller: $e');
      }
    }
    debugPrint('ProfileVideoPlayer: All controllers paused.');
  }

  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;

    _disposingControllers.add(videoId);

    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);

        try {
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          await controller.dispose();
          debugPrint('ProfileVideoPlayer: Disposed controller for $videoId');
        } catch (e) {
          debugPrint(
            'ProfileVideoPlayer: Error disposing controller $videoId: $e',
          );
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      if (!_disposingControllers.contains(oldestId)) {
        _removeController(oldestId);
      } else {
        _accessOrder.remove(oldestId);
      }
    }
  }

  Future<void> _disposeAllControllers() async {
    debugPrint('ProfileVideoPlayer: Disposing all controllers...');
    final controllerIds = List<String>.from(
      _controllerCache.keys,
    );
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
    debugPrint('ProfileVideoPlayer: All controllers disposed.');
  }

  Future<void> _manageControllerWindow(int currentPage) async {
    if (widget.userVideos.isEmpty) return;

    final windowStart = (currentPage - 1).clamp(
      0,
      widget.userVideos.length - 1,
    );
    final windowEnd = (currentPage + 1).clamp(0, widget.userVideos.length - 1);

    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < widget.userVideos.length) {
        idsToKeep.add(widget.userVideos[i].id);
      }
    }

    final idsToDispose =
        _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      await _removeController(id);
    }

    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < widget.userVideos.length) {
        final video = widget.userVideos[i];
        await _getOrCreateController(
          video,
        );
      }
    }

    if (currentPage < widget.userVideos.length) {
      final currentVideoId = widget.userVideos[currentPage].id;
      await _pauseAllControllersExcept(currentVideoId);
      await _playController(currentVideoId);
    }
  }

  Future<void> _pauseAllControllersExcept(String videoIdToKeepPlaying) async {
    debugPrint(
      'ProfileVideoPlayer: Pausing all controllers except $videoIdToKeepPlaying...',
    );
    final controllers = List<VideoPlayerController>.from(
      _controllerCache.values,
    );
    for (final controller in controllers) {
      final cachedVideoId = _controllerCache.entries
          .firstWhere((entry) => entry.value == controller)
          .key;
      if (cachedVideoId != videoIdToKeepPlaying) {
        try {
          if (controller.value.isInitialized && controller.value.isPlaying) {
            await controller.pause();
            await controller.seekTo(Duration.zero);
            debugPrint('ProfileVideoPlayer: Paused controller: $cachedVideoId');
          }
        } catch (e) {
          debugPrint(
            'ProfileVideoPlayer: Error pausing controller $cachedVideoId: $e',
          );
        }
      }
    }
    debugPrint('ProfileVideoPlayer: Finished pausing others.');
  }

  Future<void> _handlePageChange(int newPage) async {
    if (widget.userVideos.isEmpty ||
        newPage < 0 ||
        newPage >= widget.userVideos.length) return;

    final previousPage = _currentPage;
    _currentPage = newPage;
    debugPrint(
      'ProfileVideoPlayer: Page changed from $previousPage to $newPage',
    );

    final isFastScroll = (newPage - previousPage).abs() > 1;

    try {
      await _pauseAllControllers();

      if (isFastScroll) {
        debugPrint(
          'ProfileVideoPlayer: Fast scroll detected. Aggressively disposing controllers.',
        );
        final currentVideoId = widget.userVideos[newPage].id;
        final idsToDispose =
            _controllerCache.keys.where((id) => id != currentVideoId).toList();

        for (final id in idsToDispose) {
          await _removeController(id);
        }
      }

      await _manageControllerWindow(newPage);

      if (newPage < widget.userVideos.length) {
        await _initializeVideo(
          newPage,
        );
      }
    } catch (e) {
      debugPrint('ProfileVideoPlayer: Error handling page change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userVideos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              Text('No videos found.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          "Daniel",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: PreloadPageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.userVideos.length,
        physics: const AlwaysScrollableScrollPhysics(),
        preloadPagesCount: 1,
        onPageChanged: (index) => _handlePageChange(index),
        itemBuilder: (context, index) {
          final videoItem = widget.userVideos[index];
          final controller = _getController(videoItem.id);

          return RepaintBoundary(
            child: VideoFeedItem(
              key: ValueKey(videoItem.id),
              controller: controller,
              videoItem: videoItem,
              currentUserId: _currentUserId!,
              // You might need to pass Cubit methods down if VideoFeedItem
              // needs to trigger like/share actions that update state/backend.
              // E.g., onLike: () => context.read<VideoFeedCubit>().toggleLike(videoItem.id),
              //       onShare: () => context.read<VideoFeedCubit>().incrementShare(videoItem.id),
              //  onLike: (videoId) {
              //     // You need to call the Cubit method to handle like/unlike logic
              //     // This will also update the VideoItem's likeCount via the Cubit state
              //      context.read<VideoFeedCubit>().toggleLike(videoId);
              //  },
              //  onShare: (videoId) {
              //    context.read<VideoFeedCubit>().incrementShare(videoId);
              //  },
              //  // Pass the liked status from the main Cubit state (needed for UI updates)
              //  isLiked: context.select<VideoFeedCubit, bool>(
              //   (cubit) => cubit.state.likedVideoIds.contains(videoItem.id)),
            ),
          );
        },
      ),
    );
  }
}
