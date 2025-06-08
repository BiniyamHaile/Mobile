// lib/widgets/camera_toggle_button_overlay.dart
import 'package:flutter/material.dart';

class CameraToggleButtonOverlay extends StatelessWidget {
  final double safeAreaTop;
  final bool isBusy;
  final bool isFrontCamera;
  final VoidCallback? onPressed;

  const CameraToggleButtonOverlay({
    Key? key,
    required this.safeAreaTop,
    required this.isBusy, // Keep isBusy for opacity control if needed
    required this.isFrontCamera,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: safeAreaTop + 16.0, // Position below safe area
      right: 16.0,
      child: SafeArea( // Ensure padding respects notch/status bar
        child: Opacity(
          opacity: isBusy ? 0.5 : 1.0, // Visual feedback for disabled state based on isBusy
          child: IconButton(
            icon: Icon(
              isFrontCamera ? Icons.camera_front_outlined : Icons.camera_rear_outlined,
              color: Colors.white,
              size: 30, // Slightly smaller icon
            ),
            onPressed: onPressed, // Pass the parent's logic (already null if busy)
          ),
        ),
      ),
    );
  }
}