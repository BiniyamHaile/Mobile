// lib/widgets/video_preview/video_controls_overlay.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'scrubbable_video_progress_bar.dart'; // Import the progress bar widget


class VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlayPause;
  final VoidCallback onScrubStart;
  final VoidCallback onScrubEnd;
  // Add other callbacks here if needed for future controls (e.g., fullscreen)

  const VideoControlsOverlay({
    Key? key,
    required this.controller,
    required this.onPlayPause,
    required this.onScrubStart,
    required this.onScrubEnd,
  }) : super(key: key);

   // Helper function to format duration (Can also be in main screen or utility)
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


  @override
  Widget build(BuildContext context) {
    // Check if the controller is initialized before building controls
    if (!controller.value.isInitialized) {
      return Container(); // Return empty container if not initialized
    }

    // Show a larger centered play button only when paused or at the end
    final bool showCenteredPlay = !controller.value.isPlaying && controller.value.isInitialized;


    return Stack(
      children: <Widget>[
        // Optional: A semi-transparent gradient or background behind controls for contrast
        Positioned.fill(
          child: Column( // Use column to position top/bottom elements
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               // Top gradient or controls if any
               // Container(height: 50, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent]))),
               const Expanded(child: SizedBox.shrink()), // Takes up space
               // Bottom gradient or controls area
               Container(
                  // Match the height needed for the bottom row of controls
                  height: 50, // Approx height for play/pause + progress bar
                  decoration: const BoxDecoration(
                     gradient: LinearGradient( // Subtle gradient at the bottom
                       begin: Alignment.bottomCenter,
                       end: Alignment.topCenter,
                       colors: [Colors.black87, Colors.transparent],
                     ),
                  ),
               ),
             ],
          ),
        ),


        // Centered Play Button (shows when paused/ended)
        if (showCenteredPlay)
           Positioned.fill(
             child: Center(
               child: IconButton(
                  icon: Icon(
                     controller.value.position >= controller.value.duration && controller.value.duration > Duration.zero
                        ? Icons.replay // Show replay icon if video ended
                        : Icons.play_circle_fill, // Show play icon otherwise
                     color: Colors.white,
                     size: 80.0, // Large size for the main play button
                  ),
                  onPressed: onPlayPause, // This handles play/replay
               ),
             ),
           ),


        // Bottom Control Bar (Play/Pause + Progress Bar)
         Positioned(
           bottom: 0,
           left: 0,
           right: 0,
            // Using a Container for background and padding
           child: Container(
              color: Colors.black.withOpacity(0.2), // Slightly more transparent background
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row( // Arrange play/pause and progress bar
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Play/Pause Button (smaller, always visible when controls are shown)
                  IconButton(
                    iconSize: 30.0,
                    color: Colors.white,
                    icon: Icon(
                      controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: onPlayPause, // Use the passed callback
                  ),

                   // Current time display
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                     child: Text(
                         _formatDuration(controller.value.position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                       ),
                   ),


                  // Custom Scrubbable Progress Bar with Knob
                  Expanded( // Progress bar takes available space
                    child: ScrubbableVideoProgressBar( // Use the external widget
                      controller: controller, // Pass the controller
                      barHeight: 4.0,
                      knobRadius: 8.0,
                      playedColor: Theme.of(context).colorScheme.primary, // Use theme color
                      bufferedColor: Colors.white54, // Use white54 for buffered
                      backgroundColor: Colors.white30, // Use white30 for background
                      onDragStart: onScrubStart, // Pass callback
                      onDragEnd: onScrubEnd, // Pass callback
                    ),
                  ),

                   // Total duration display
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                     child: Text(
                         _formatDuration(controller.value.duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                       ),
                   ),
                ],
              ),
           ),
         ),
      ],
    );
  }
}