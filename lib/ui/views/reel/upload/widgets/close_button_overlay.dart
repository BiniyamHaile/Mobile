// lib/widgets/close_button_overlay.dart
import 'package:flutter/material.dart';

class CloseButtonOverlay extends StatelessWidget {
  final double safeAreaTop;
  final bool isBusy;
  final VoidCallback? onPressed; // Nullable to be explicitly disabled

  const CloseButtonOverlay({
    Key? key,
    required this.safeAreaTop,
    required this.isBusy, // Keep isBusy for opacity control if needed
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: safeAreaTop + 8.0, // Position below safe area, slightly less padding
      left: 8.0,
      child: SafeArea( // Ensure padding respects notch/status bar
        child: Opacity(
          opacity: isBusy ? 0.5 : 1.0, // Visual feedback for disabled state based on isBusy
          child: IconButton(
            icon: const Icon(
              Icons.close, // 'X' icon
              color: Colors.white,
              size: 30,
            ),
            onPressed: onPressed, // Pass the parent's logic (already null if busy)
          ),
        ),
      ),
    );
  }
}