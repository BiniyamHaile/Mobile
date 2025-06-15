import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/views/reel/upload/widgets/video_controls_overlay.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  const VideoPreviewScreen({Key? key, required this.videoPath})
    : super(key: key);

  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _controller;
  bool _showControls = true;
  Timer? _hideTimer;

  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..addListener(_videoPlayerListener)
      ..initialize()
          .then((_) {
            if (!mounted) return;
            setState(() {
              _isInitialized = _controller?.value.isInitialized ?? false;
              if (_isInitialized) {
                _controller!.play();
                _startHideTimer();
              }
            });
          })
          .catchError((e) {
            print("Error initializing video player: $e");
            if (!mounted) return;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    'Error playing video: ${e.toString()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            });
            setState(() {
              _isInitialized = false;
              _controller = null;
            });
          });
  }

  void _videoPlayerListener() {
    if (!mounted) return;

    final bool newIsPlaying = _controller?.value.isPlaying ?? false;
    if (newIsPlaying != _isPlaying) {
      setState(() {
        _isPlaying = newIsPlaying;
      });
    }

    if (_controller != null &&
        _controller!.value.position >= _controller!.value.duration &&
        _controller!.value.duration > Duration.zero) {
      if (_showControls == false) {
        setState(() {
          _showControls = true;
        });
        _cancelHideTimer();
      }
    }
  }

  void _startHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_showControls && mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  void _resetHideTimer() {
    _cancelHideTimer();
    if (_controller != null && _controller!.value.isPlaying) {
      _startHideTimer();
    }
  }

  void _toggleControlsVisibility() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _resetHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  @override
  void dispose() {
    print("VideoPreviewScreen disposing controller...");
    _controller?.removeListener(_videoPlayerListener);
    _controller?.dispose();
    _cancelHideTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isControllerInitialized = _isInitialized;
        final theme = AppTheme.getTheme(context);


    Widget content;
    if (!isControllerInitialized) {
      if (widget.videoPath != null && _controller == null) {
        content =  Text(
          "Failed to load video.",
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 18),
        );
      } else {
        content = const CircularProgressIndicator();
      }
    } else {
      content = Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControlsVisibility,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: VideoControlsOverlay(
                controller: _controller!,
                onPlayPause: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                  _resetHideTimer();
                },
                onScrubStart: _cancelHideTimer,
                onScrubEnd: _resetHideTimer,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Center(child: content)),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  color: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: isControllerInitialized
                                ? () {
                                    _controller?.pause();
                                    _cancelHideTimer();
                                    Navigator.pop(context);
                                  }
                                : null,
                            icon:  Icon(
                              Icons.videocam,
                              color: theme.colorScheme.primary,
                            ),
                            label:  Text(
                              'Record Again',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: isControllerInitialized
                                ? () {
                                    _controller?.pause();
                                    _cancelHideTimer();
                                    GoRouter.of(context).push(
                                      RouterEnum.postScreen.routeName
                                          .replaceAll(
                                            ':videoPath',
                                            Uri.encodeComponent(
                                              widget.videoPath!,
                                            ),
                                          ),
                                    );
                                  }
                                : null,
                            icon:  Icon(Icons.send, color:theme.colorScheme.primary),
                            label:  Text(
                              'Next',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
