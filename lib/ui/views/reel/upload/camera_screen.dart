import 'dart:async';

import 'package:camera/camera.dart' hide ImageFormat;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;

import 'widgets/camera_error_widget.dart';
import 'widgets/camera_initializing_widget.dart';
import 'widgets/camera_preview_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  List<CameraDescription>? _cameras;
  bool _isFrontCamera = false;

  String? _lastVideoPath;
  String? _lastThumbnailPath;

  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  int _countdownValue = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print("No cameras available");
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No cameras available on this device.'),
              ),
            );
          });

          final Completer<void> completer = Completer<void>();
          _initializeControllerFuture = completer.future;
          completer.complete();
        }
        return;
      }

      CameraDescription selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      final Completer<void> completer = Completer<void>();
      _initializeControllerFuture = completer.future;

      _controller!.initialize().then((_) {
        if (!mounted) {
          completer.complete();
          return;
        }
        setState(() {});
        completer.complete();
      }).catchError((e, stackTrace) {
        print("Error initializing camera: $e \n StackTrace: $stackTrace");
        if (!mounted) {
          completer.completeError(e, stackTrace);
          return;
        }
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error initializing camera: ${e.toString()}'),
            ),
          );
        });
        setState(() {});
        completer.completeError(e, stackTrace);
      });
    } catch (e, stackTrace) {
      print("Fatal error listing cameras: $e \n StackTrace: $stackTrace");
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fatal error accessing cameras: ${e.toString()}'),
            ),
          );
        });

        final Completer<void> completer = Completer<void>();
        _initializeControllerFuture = completer.future;
        completer.complete();
      }
      setState(() {});
    }
  }

  Future<void> _toggleCamera() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording ||
        _countdownValue > 0 ||
        _cameras == null ||
        _cameras!.isEmpty ||
        _cameras!.length < 2) return;

    final CameraDescription newCamera = _isFrontCamera
        ? _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first,
          )
        : _cameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras!.first,
          );

    if (_controller!.description.lensDirection == newCamera.lensDirection) {
      return;
    }

    try {
      if (_controller!.value.isRecordingVideo) {
        await _controller!.stopVideoRecording();
        _stopTimer();
        setState(() {
          _isRecording = false;
          _recordingDuration = Duration.zero;
        });
      }
      await _controller!.dispose();
    } catch (e) {
      print("Error disposing old controller: $e");
    }

    _controller = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    final Completer<void> completer = Completer<void>();
    _initializeControllerFuture = completer.future;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });

    _controller!.initialize().then((_) {
      if (!mounted) {
        completer.complete();
        return;
      }
      setState(() {});
      completer.complete();
    }).catchError((e, stackTrace) {
      print("Error toggling camera: $e \n StackTrace: $stackTrace");
      if (!mounted) {
        completer.completeError(e, stackTrace);
        return;
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching camera: ${e.toString()}')),
        );
      });
      setState(() {});
      completer.completeError(e, stackTrace);
    });
  }

  Future<void> _generateAndSetThumbnail(String videoPath) async {
    if (videoPath.isEmpty) {
      setState(() {
        _lastThumbnailPath = null;
      });
      return;
    }
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await video_thumbnail.VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: video_thumbnail.ImageFormat.JPEG,
        maxWidth: 150,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          _lastThumbnailPath = thumbnailPath;
        });
      }
    } catch (e) {
      print("Error generating thumbnail for $videoPath: $e");
      if (mounted) {
        setState(() {
          _lastThumbnailPath = null;
        });
      }
    }
  }

  Future<void> _startRecordingCountdown() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording ||
        _countdownValue > 0) {
      return;
    }

    setState(() {
      _countdownValue = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _countdownValue = 0;
        });
        if (_controller != null &&
            _controller!.value.isInitialized &&
            !_isRecording) {
          _startRecording();
        } else {
          print("Camera not ready to start recording after countdown.");
        }
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _controller!.value.isRecordingVideo) {
      return;
    }
    try {
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      await _controller!.startVideoRecording();
      _startTimer();
    } catch (e) {
      print("Error starting recording: $e");
      setState(() {
        _isRecording = false;
      });
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _recordingDuration = _recordingDuration + const Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      if (_isRecording) {
        setState(() {
          _isRecording = false;
        });
      }
      _stopTimer();
      return;
    }
    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      _stopTimer();
      setState(() {
        _isRecording = false;
      });
      _lastVideoPath = videoFile.path;
      _generateAndSetThumbnail(videoFile.path);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _lastVideoPath != null) {
          GoRouter.of(context).push(
            RouterEnum.videoPreviewScreen.routeName.replaceAll(
              ':videoPath',
              Uri.encodeComponent(_lastVideoPath!),
            ),
          );
        }
      });
    } catch (e) {
      print("Error stopping recording: $e");
      setState(() {
        _isRecording = false;
      });
      _stopTimer();
    }
  }

  void _stopTimer() {
    if (_recordingTimer != null && _recordingTimer!.isActive) {
      _recordingTimer!.cancel();
    }
  }

  Future<void> _pickVideo() async {
    if (_isRecording || _countdownValue > 0) {
      print("Cannot pick file while recording or during countdown.");
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Stop recording/countdown before picking a file')),
          );
        });
      }
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String? videoPath = result.files.single.path;
        if (videoPath != null) {
          setState(() {
            _lastVideoPath = videoPath;
          });
          _generateAndSetThumbnail(videoPath);
          if (mounted) {
            GoRouter.of(context).push(
              RouterEnum.videoPreviewScreen.routeName.replaceAll(
                ':videoPath', Uri.encodeComponent(videoPath),
              ),
            );
          }
        }
      } else {
        print("File picking cancelled or no file selected.");
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('File picking cancelled')));
          });
        }
      }
    } catch (e) {
      print("Error picking video file: $e");
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking file: ${e.toString()}')),
          );
        });
      }
    }
  }

  void _goToLastPreview() {
    if (_isRecording || _countdownValue > 0) {
      return;
    }

    if (_lastVideoPath != null) {
      if (mounted) {
        GoRouter.of(context).push(
          RouterEnum.videoPreviewScreen.routeName.replaceAll(
            ':videoPath', Uri.encodeComponent(_lastVideoPath!),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video recorded or picked yet')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  void _onClosePressed() {
    if (_isRecording || _countdownValue > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stop recording/countdown before closing')),
      );
      return;
    }
    if (mounted) {
      GoRouter.of(context).go(RouteNames.home);
    }
  }

  void _onToggleRecord() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecordingCountdown();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _stopTimer();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isControllerInitialized =
        _controller?.value.isInitialized ?? false;
    final double safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          final bool isInitializing =
              snapshot.connectionState != ConnectionState.done;

          if (isInitializing) {
            return const CameraInitializingWidget();
          }

          if (_controller == null || !isControllerInitialized) {
            return CameraErrorWidget(snapshot: snapshot);
          }

          final bool isBusy = _isRecording || _countdownValue > 0;

          return CameraPreviewOverlay(
            controller: _controller!,
            safeAreaTop: safeAreaTop,
            isBusy: isBusy,
            isRecording: _isRecording,
            recordingDuration: _recordingDuration,
            countdownValue: _countdownValue,
            cameras: _cameras,
            isFrontCamera: _isFrontCamera,
            lastVideoPath: _lastVideoPath,
            lastThumbnailPath: _lastThumbnailPath,
            onClosePressed: isBusy ? null : _onClosePressed,
            onToggleCamera: (isBusy || _cameras == null || _cameras!.length < 2)
                ? null
                : _toggleCamera,
            onPickVideo: isBusy ? null : _pickVideo,
            onToggleRecord: (_countdownValue > 0) ? null : _onToggleRecord,
            onGoToLastPreview:
                (isBusy || _lastVideoPath == null) ? null : _goToLastPreview,
            formatDuration: _formatDuration,
          );
        },
      ),
    );
  }
}
