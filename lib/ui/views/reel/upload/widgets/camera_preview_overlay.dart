import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'bottom_control_bar_overlay.dart';
import 'camera_toggle_button_overlay.dart';
import 'close_button_overlay.dart';
import 'countdown_overlay.dart';
import 'recording_timer_overlay.dart';

class CameraPreviewOverlay extends StatelessWidget {
  final CameraController controller;
  final double safeAreaTop;
  final bool isBusy;
  final bool isRecording;
  final Duration recordingDuration;
  final int countdownValue;
  final List<CameraDescription>? cameras;
  final bool isFrontCamera;
  final String? lastVideoPath;
  final String? lastThumbnailPath;
  final VoidCallback? onClosePressed;
  final VoidCallback? onToggleCamera;
  final VoidCallback? onPickVideo;
  final VoidCallback? onToggleRecord;
  final VoidCallback? onGoToLastPreview;
  final String Function(Duration) formatDuration;

  const CameraPreviewOverlay({
    Key? key,
    required this.controller,
    required this.safeAreaTop,
    required this.isBusy,
    required this.isRecording,
    required this.recordingDuration,
    required this.countdownValue,
    required this.cameras,
    required this.isFrontCamera,
    required this.lastVideoPath,
    required this.lastThumbnailPath,
    required this.onClosePressed,
    required this.onToggleCamera,
    required this.onPickVideo,
    required this.onToggleRecord,
    required this.onGoToLastPreview,
    required this.formatDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      print("CameraPreviewOverlay built with uninitialized controller!");
      return Container(color: Colors.black);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
        CloseButtonOverlay(
          safeAreaTop: safeAreaTop,
          isBusy: isBusy,
          onPressed: onClosePressed,
        ),
        if (isRecording)
          RecordingTimerOverlay(
            safeAreaTop: safeAreaTop,
            duration: recordingDuration,
            formatDuration: formatDuration,
          ),
        if (cameras != null && cameras!.length > 1)
          CameraToggleButtonOverlay(
            safeAreaTop: safeAreaTop,
            isBusy: isBusy,
            isFrontCamera: isFrontCamera,
            onPressed: onToggleCamera,
          ),
        if (countdownValue > 0)
          CountdownOverlay(countdownValue: countdownValue),
        BottomControlBarOverlay(
          isBusy: isBusy,
          isRecording: isRecording,
          lastVideoPath: lastVideoPath,
          lastThumbnailPath: lastThumbnailPath,
          onPickVideo: onPickVideo,
          onToggleRecord: onToggleRecord,
          onGoToLastPreview: onGoToLastPreview,
        ),
      ],
    );
  }
}
