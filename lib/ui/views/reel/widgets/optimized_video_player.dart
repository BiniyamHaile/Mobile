// import 'package:flutter/material.dart';
// import 'package:mobile/ui/styles/app_colors.dart';
// import 'package:video_player/video_player.dart';

// class OptimizedVideoPlayer extends StatefulWidget {
//   const OptimizedVideoPlayer({Key? key, required this.controller, required this.videoId}) : super(key: key);

//   final VideoPlayerController? controller;
//   final String videoId;

//   @override
//   State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
// }

// class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> with SingleTickerProviderStateMixin {
//   late AnimationController _loadingController;
//   bool _isBuffering = false;
//   VideoPlayerController? _oldController;
//   String? _currentVideoId;
//   bool _isPlaying = false;
//   Key _playerKey = UniqueKey();

//   final appColors = AppColors();

//   @override
//   void initState() {
//     super.initState();
//     _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
//     _oldController = widget.controller;
//     _currentVideoId = widget.videoId;
//     _addControllerListener();
//   }

//   void _addControllerListener() {
//     if (widget.controller != null) {
//       _isBuffering = widget.controller!.value.isBuffering;
//       _isPlaying = widget.controller!.value.isPlaying;
//       widget.controller!.addListener(_onControllerUpdate);
//     }
//   }

//   @override
//   void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     final bool videoIdChanged = widget.videoId != _currentVideoId;
//     final bool controllerChanged = widget.controller != _oldController;

//     if (videoIdChanged || controllerChanged) {
//       _oldController?.removeListener(_onControllerUpdate);
//       _oldController = widget.controller;
//       _currentVideoId = widget.videoId;
//       _playerKey = UniqueKey();
//       _addControllerListener();

//       final bool shouldUpdateBuffering = widget.controller?.value.isBuffering ?? false;
//       if (mounted && _isBuffering != shouldUpdateBuffering) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _isBuffering = shouldUpdateBuffering;
//             });
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _loadingController.dispose();
//     _oldController?.removeListener(_onControllerUpdate);
//     _oldController = null;
//     super.dispose();
//   }

//   void _onControllerUpdate() {
//     if (!mounted) return;

//     final controller = widget.controller;
//     if (controller == null) return;

//     if (widget.videoId != _currentVideoId) return;

//     if (controller.value.hasError) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) setState(() => _isBuffering = false);
//       });
//       return;
//     }

//     final isBuffering = controller.value.isBuffering;
//     final isPlaying = controller.value.isPlaying;

//     bool shouldShowBuffering = isBuffering;
//     if ((isPlaying && controller.value.position > Duration.zero) ||
//         (controller.value.position > Duration.zero && controller.value.duration.inMilliseconds > 0)) {
//       shouldShowBuffering = false;
//     }

//     if (_isBuffering != shouldShowBuffering || _isPlaying != isPlaying) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _isBuffering = shouldShowBuffering;
//             _isPlaying = isPlaying;
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = widget.controller;

//     if (controller == null || !controller.value.isInitialized) {
//       return Center(
//         child: RotationTransition(
//           turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
//           child: CircularProgressIndicator(color: appColors.whiteColor),
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap: () {
//         if (controller.value.isPlaying) {
//           controller
//               .pause()
//               .then((_) {
//                 if (mounted) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     if (mounted) setState(() {});
//                   });
//                 }
//               })
//               .catchError((e) {
//                 debugPrint('Error pausing video: $e');
//               });
//         } else {
//           controller
//               .play()
//               .then((_) {
//                 if (mounted) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     if (mounted) setState(() {});
//                   });
//                 }
//               })
//               .catchError((e) {
//                 debugPrint('Error playing video: $e');
//               });
//         }
//       },
//       child: SizedBox.expand(
//         child: FittedBox(
//           key: _playerKey,
//           fit: BoxFit.cover,
//           child: Stack(
//             children: [
//               VideoPlayer(controller),
//               if (_isBuffering) const Center(child: CircularProgressIndicator()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile/ui/styles/app_colors.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer(
      {Key? key, required this.controller, required this.videoId})
      : super(key: key);

  final VideoPlayerController? controller;
  final String videoId;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  bool _isBuffering = false;
  VideoPlayerController?
      _oldController; 
  String? _currentVideoId;
  bool _isPlaying = false;
  Key _playerKey =
      UniqueKey(); 

  final appColors = AppColors();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _oldController = widget
        .controller; 
    _currentVideoId = widget.videoId;
    _addControllerListener(); 
  }

  void _addControllerListener() {
    if (widget.controller != null) {
      try {
        _isBuffering = widget.controller!.value.isBuffering;
        _isPlaying = widget.controller!.value.isPlaying;
        widget.controller!.addListener(_onControllerUpdate);
        debugPrint('Listener added for video ${widget.videoId}');
      } catch (e) {
        debugPrint(
            'Error adding listener to controller for ${widget.videoId}: $e');
        _isBuffering = false;
        _isPlaying = false;
      }
    } else {
      _isBuffering = false;
      _isPlaying = false;
      debugPrint('No controller for ${widget.videoId}. Listener not added.');
    }
  }

  void _removeControllerListener() {
    if (_oldController != null) {
      try {
        _oldController!.removeListener(_onControllerUpdate);
        debugPrint(
            'Listener removed from video ${_currentVideoId ?? "unknown"}');
      } catch (e) {
        debugPrint(
            'Error removing listener from potentially disposed controller ${_currentVideoId ?? "unknown"}: $e');
      }
    }
  }

  @override
  void didUpdateWidget(OptimizedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool videoIdChanged = widget.videoId != _currentVideoId;
    final bool controllerChanged = widget.controller != _oldController;

    if (videoIdChanged || controllerChanged) {
      debugPrint(
          'didUpdateWidget: videoIdChanged: $videoIdChanged, controllerChanged: $controllerChanged');
      debugPrint(
          'Old videoId: ${_currentVideoId}, New videoId: ${widget.videoId}');
      debugPrint(
          'Old controller: ${_oldController}, New controller: ${widget.controller}');

      _removeControllerListener();

      _oldController = widget.controller; 
      _currentVideoId = widget.videoId;
      _playerKey =
          UniqueKey(); 

      _addControllerListener();
      if (mounted) {
        final bool newIsBuffering =
            widget.controller?.value.isBuffering ?? false;
        final bool newIsPlaying = widget.controller?.value.isPlaying ?? false;

        if (_isBuffering != newIsBuffering || _isPlaying != newIsPlaying) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBuffering = newIsBuffering;
                _isPlaying = newIsPlaying;
              });
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _removeControllerListener(); 
    _oldController = null; 
    debugPrint(
        'OptimizedVideoPlayer disposed for video ${_currentVideoId ?? "unknown"}');
    super.dispose();
  }

  void _onControllerUpdate() {
    try {
      if (!mounted) return; 

      final controller = widget.controller;
      if (controller == null || widget.videoId != _currentVideoId) {
        if (widget.videoId != _currentVideoId) {
        }
        return;
      }

      final value = controller.value;

      if (!value.isInitialized) {
        if (_isBuffering != true || _isPlaying != false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isBuffering = true;
                _isPlaying = false;
              });
            }
          });
        }
        return; 
      }

      if (value.hasError) {
        debugPrint(
            'Controller error for ${widget.videoId}: ${value.errorDescription}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = false;
              _isPlaying = false;
            });
          }
        });
        return;
      }

      final bool currentIsBuffering = value.isBuffering;
      final bool currentIsPlaying = value.isPlaying;

      bool shouldShowBufferingIndicator =
          currentIsBuffering; 

      if (value.isInitialized &&
          currentIsPlaying &&
          value.position > Duration.zero) {
        shouldShowBufferingIndicator = false;
      }

      if (_isBuffering != shouldShowBufferingIndicator ||
          _isPlaying != currentIsPlaying) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = shouldShowBufferingIndicator;
              _isPlaying = currentIsPlaying;
            });
          }
        });
      }
    } catch (e) {
      debugPrint(
          'Caught error in _onControllerUpdate for video ${_currentVideoId ?? "unknown"}: $e');
      widget.controller
          ?.removeListener(_onControllerUpdate); 
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isBuffering = false;
              _isPlaying = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) {
      debugPrint(
          'Building: Controller null or not initialized for ${widget.videoId}');
      return Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_loadingController),
          child: CircularProgressIndicator(color: appColors.blackColor),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!controller.value.isInitialized) {
          debugPrint('Tap ignored: Controller not ready for ${widget.videoId}');
          return;
        }

        if (controller.value.isPlaying) {
          debugPrint('Pausing video ${widget.videoId}');
          controller.pause().then((_) {}).catchError((e) {
            debugPrint('Error pausing video ${widget.videoId}: $e');
          });
        } else {
          debugPrint('Playing video ${widget.videoId}');
          if (controller.value.isInitialized) {
            controller.play().then((_) {
            }).catchError((e) {
              debugPrint('Error playing video ${widget.videoId}: $e');
            });
          } else {
            debugPrint(
                'Controller not initialized, cannot play ${widget.videoId}');
          }
        }
      },
      child: SizedBox.expand(
        child: FittedBox(
          key:
              _playerKey, 
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: Stack(
              children: [
                VideoPlayer(controller),
                if (_isBuffering && controller.value.isInitialized)
                  const Center(child: CircularProgressIndicator()),
                if (!_isPlaying &&
                    !_isBuffering &&
                    controller.value.isInitialized)
                  const Center(
                    child: Icon(Icons.play_arrow,
                        size: 80.0, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
