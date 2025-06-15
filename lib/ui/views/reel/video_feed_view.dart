import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/bloc/reel/reel_state.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/views/reel/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView>
    with WidgetsBindingObserver {
  final int _maxCacheSize = 3;

  List<VideoItem> _videos = [];

  int _currentPage = 0;

  final PreloadPageController _pageController = PreloadPageController();

  bool _isAppActive = true;

  final Map<String, VideoPlayerController> _controllerCache = {};

  final List<String> _accessOrder = [];

  final Set<String> _disposingControllers = Set<String>();

  ReelActionStatus? _lastHandledActionStatus;

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideo();
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

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<ReelFeedAndActionBloc>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);

        await _initAndPlayVideo(0);
      }
    });
  }

  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    await _pauseAllControllers();

    final videoId = _videos[_currentPage].id;
    final controller = _getController(videoId);

    if (controller != null &&
        (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _initAndPlayVideo(_currentPage);
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
        'Error fetching userId from SharedPreferences in VideoFeedView: $e',
      );
      if (mounted) {
        setState(() {
          _currentUserId = null;
        });
      }
    }
  }

  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;

    final video = _videos[index];
    await _getOrCreateController(video);
    await _playController(video.id);

    if (mounted) setState(() {});
  }

  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  Future<VideoPlayerController?> _getOrCreateController(VideoItem video) async {
    if (_controllerCache.containsKey(video.id)) {
      _touchController(video.id);
      return _controllerCache[video.id];
    }

    try {
      final videoFile = await context
          .read<ReelFeedAndActionBloc>()
          .getCachedVideoFile(video.videoUrl);

      if (videoFile == null) {
        debugPrint('Cached file not found for ${video.videoUrl}');
        return null;
      }

      final controller = VideoPlayerController.file(videoFile);

      await controller.initialize();

      controller.setLooping(true);

      _controllerCache[video.id] = controller;
      _touchController(video.id);

      _enforceCacheLimit();

      return controller;
    } catch (e) {
      debugPrint('The device does not allow this operation for ${video.videoUrl}...');
      return null;
    }
  }

  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        debugPrint('Error playing video $videoId: $e');
      }
    }
  }

  Future<void> _pauseAllControllers() async {
    final controllers = List<VideoPlayerController>.from(
      _controllerCache.values,
    );

    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
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
        } catch (e) {
          debugPrint('Error disposing controller for $videoId: $e');
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  void _enforceCacheLimit() {
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      if (_videos.isNotEmpty && _currentPage < _videos.length) {
        final windowStart = (_currentPage - 1).clamp(
          0,
          _videos.length > 0 ? _videos.length - 1 : 0,
        );
        final windowEnd = (_currentPage + 1).clamp(
          0,
          _videos.length > 0 ? _videos.length - 1 : 0,
        );
        final idsInWindow = <String>{};
        for (int i = windowStart; i <= windowEnd; i++) {
          if (i >= 0 && i < _videos.length) idsInWindow.add(_videos[i].id);
        }
        if (idsInWindow.contains(oldestId)) {
          break;
        }
      }
      _removeController(oldestId);
    }
  }

  Future<void> _disposeAllControllers() async {
    final controllerIds = List<String>.from(_controllerCache.keys);
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;

    final windowStart = (currentPage - 1).clamp(
      0,
      _videos.length > 0 ? _videos.length - 1 : 0,
    );
    final windowEnd = (currentPage + 1).clamp(
      0,
      _videos.length > 0 ? _videos.length - 1 : 0,
    );

    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i >= 0 && i < _videos.length) {
        idsToKeep.add(_videos[i].id);
      }
    }

    final idsToDispose = _controllerCache.keys
        .where((id) => !idsToKeep.contains(id))
        .toList();
    for (final id in idsToDispose) {
      await _removeController(id);
    }

    if (currentPage >= 0 && currentPage < _videos.length) {
      await _getOrCreateController(_videos[currentPage]);

      if (windowStart < currentPage && windowStart >= 0) {
        if (windowStart < _videos.length) {
          await _getOrCreateController(_videos[windowStart]);
        }
      }

      if (windowEnd > currentPage && windowEnd < _videos.length) {
        if (windowEnd >= 0) {
          await _getOrCreateController(_videos[windowEnd]);
        }
      }
    }
  }

  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage < 0 || newPage >= _videos.length) return;

    final previousPage = _currentPage;
    _currentPage = newPage;

    final isFastScroll = (newPage - previousPage).abs() > 1;

    await _pauseAllControllers();

    try {
      if (isFastScroll) {
        if (_videos.isNotEmpty && newPage < _videos.length) {
          final videoId = _videos[newPage].id;
          final idsToDispose = List<String>.from(_controllerCache.keys);

          for (final id in idsToDispose) {
            if (id != videoId) {
              await _removeController(id);
            }
          }
        } else {
          await _disposeAllControllers();
        }
      }

      await _manageControllerWindow(newPage);

      if (_videos.isNotEmpty && newPage < _videos.length) {
        await _initAndPlayVideo(newPage);
      }

      context.read<ReelFeedAndActionBloc>().add(VideoPageChanged(newPage));
    } catch (e) {
      debugPrint('Error handling page change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: theme.colorScheme.primary),
            color: Colors.red,
            tooltip: 'Create Reel',
            focusColor: theme.colorScheme.primary.withOpacity(0.2),
            highlightColor: theme.colorScheme.primary.withOpacity(0.2),
            onPressed: () {
              GoRouter.of(context).go(RouterEnum.cameraScreen.routeName);
            },
          ),
          IconButton(
            onPressed: () {
              context.push(RouteNames.notifications);
            },
            icon: Icon(LucideIcons.bell, color: theme.colorScheme.primary),
          ),
        ],
      ),
      body: RepaintBoundary(
        child: BlocListener<ReelFeedAndActionBloc, ReelFeedAndActionState>(
          listenWhen: (p, c) =>
              p.videos != c.videos ||
              p.isLoadingFeed != c.isLoadingFeed ||
              p.preloadedVideoUrls != c.preloadedVideoUrls ||
              p.isPaginatingFeed != c.isPaginatingFeed ||
              p.actionStatus != c.actionStatus,
          listener: (context, state) {
            setState(() => _videos = state.videos);
            _manageControllerWindow(_currentPage);

            if (state.isLoadingFeed) {
              // Optionally handle loading state
            } else {}
            if (state.isPaginatingFeed) {
              // Optionally handle pagination
            } else {}

            if (state.actionStatus == ReelActionStatus.reportSuccess &&
                _lastHandledActionStatus != ReelActionStatus.reportSuccess) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    title: const Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Report Submitted',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your report has been submitted successfully. It will be reviewed. Thank you for helping keep the community safe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  );
                },
              );
              _lastHandledActionStatus = ReelActionStatus.reportSuccess;
            }

            if (state.actionStatus == ReelActionStatus.deleteSuccess &&
                _lastHandledActionStatus != ReelActionStatus.deleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reel deleted successfully.',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  backgroundColor: theme.colorScheme.onPrimary,
                  duration: const Duration(seconds: 3),
                ),
              );
              _lastHandledActionStatus = ReelActionStatus.deleteSuccess;
            }

            if (state.actionStatus != ReelActionStatus.reportSuccess &&
                state.actionStatus != ReelActionStatus.deleteSuccess &&
                _lastHandledActionStatus != null) {
              _lastHandledActionStatus = null;
            }
          },
          child: _videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.videoOff,
                        size: 80,
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Reels Available',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Be the first to create a reel or check back later!',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.primary.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          GoRouter.of(context).go(RouterEnum.cameraScreen.routeName);
                        },
                        icon: Icon(Icons.videocam, color: theme.colorScheme.onPrimary),
                        label: Text(
                          'Create a Reel',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : PreloadPageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: _videos.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  onPageChanged: (index) => _handlePageChange(index),
                  itemBuilder: (context, index) {
                    if (index < 0 || index >= _videos.length) {
                      return const SizedBox.shrink();
                    }
                    return RepaintBoundary(
                      child: VideoFeedItem(
                        key: ValueKey(_videos[index].id),
                        controller: _getController(_videos[index].id),
                        videoItem: _videos[index],
                        currentUserId: _currentUserId ?? '',
                      ),
                    );
                  },
                  preloadPagesCount: 1,
                ),
        ),
      ),
    );
  }
}
