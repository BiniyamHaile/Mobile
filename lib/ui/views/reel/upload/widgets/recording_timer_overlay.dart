// lib/widgets/recording_timer_overlay.dart
import 'package:flutter/material.dart';

class RecordingTimerOverlay extends StatelessWidget {
  final double safeAreaTop;
  final Duration duration;
  final String Function(Duration) formatDuration;

  const RecordingTimerOverlay({
    Key? key,
    required this.safeAreaTop,
    required this.duration,
    required this.formatDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: safeAreaTop + 16.0, // Position below safe area
      left: 50.0, // Shift slightly right to avoid close button
      child: SafeArea( // Ensure padding respects notch/status bar
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.black54, // Semi-transparent background
            borderRadius: BorderRadius.circular(20), // Rounded capsule shape
          ),
          child: Text(
            formatDuration(duration), // Use the passed formatter
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}