// lib/widgets/bottom_control_bar_overlay.dart
import 'dart:io'; // Needed for File

import 'package:flutter/material.dart';

class BottomControlBarOverlay extends StatelessWidget {
  final bool isBusy;
  final bool isRecording; // <--- This is declared and required
  final String? lastVideoPath;
  final String? lastThumbnailPath;
  final VoidCallback? onPickVideo;
  final VoidCallback? onToggleRecord; // Unified callback
  final VoidCallback? onGoToLastPreview;

  const BottomControlBarOverlay({
    Key? key,
    required this.isBusy,
    required this.isRecording, // <--- This is required
    required this.lastVideoPath,
    required this.lastThumbnailPath,
    required this.onPickVideo,
    required this.onToggleRecord,
    required this.onGoToLastPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Opacity for the entire control bar based on busy state
    // We only apply dimming here based on isBusy (which includes countdown).
    // The *Record* button's specific dimming during countdown is handled by its
    // onPressed being null in the parent, combined with Opacity in the button itself if desired.
    // Let's keep the whole bar dimming if anything other than recording is busy.
    final bool isOtherBusy = isBusy && !isRecording; // <-- 'isRecording' is used here, it's available
    final double barOpacity = isOtherBusy ? 0.5 : 1.0;

    return Positioned(
      bottom: 24.0 + MediaQuery.of(context).padding.bottom, // Distance from bottom edge + safe area
      left: 0,
      right: 0,
      child: Center( // Center the control bar horizontally
        child: Opacity(
          opacity: barOpacity, // Apply opacity to the container
          child: Container(
             // Added constraints for a fixed width on wider screens, optional
             // constraints: BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.black54, // Semi-transparent background
              borderRadius: BorderRadius.circular(40), // More rounded capsule shape
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row takes minimum space needed
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute icons evenly
              children: [
                // File Upload Button
                IconButton(
                  icon: const Icon(
                    Icons.folder_open_outlined, // Outline version often looks cleaner
                    size: 40, // Adjusted size to fit better
                    color: Colors.white,
                  ),
                  onPressed: onPickVideo, // onPressed is nullified in CameraScreen if busy
                ),

                const SizedBox(width: 24.0), // Space between icons

                // Record Button
                 Opacity( // Apply specific opacity for the record button during countdown
                    opacity: isBusy && !isRecording ? 0.5 : 1.0, // <-- 'isRecording' is used here, it's available
                    child: IconButton(
                       icon: Icon(
                           isRecording ? Icons.stop : Icons.fiber_manual_record, // <-- 'isRecording' is used here, it's available
                           color: Colors.red, // Keep red for recording
                           size: 70, // Larger size for the main action
                         ),
                       onPressed: onToggleRecord, // onPressed is nullified in CameraScreen ONLY during countdown
                     ),
                 ),


                const SizedBox(width: 24.0), // Space between icons


                // Last Preview Button (with thumbnail)
                InkWell(
                  onTap: onGoToLastPreview, // onPressed is nullified in CameraScreen if busy or no video
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: lastThumbnailPath != null
                          ? Colors.white // White background if thumbnail exists
                          : Colors.black26, // Darker background if no thumbnail yet
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.0),
                      border: lastThumbnailPath != null
                          ? Border.all(
                                color: Colors.white, // Border around thumbnail area
                                width: 1.0,
                              )
                          : null, // No border if no thumbnail
                    ),
                    child: Center( // Center content inside the thumbnail container
                      child: lastThumbnailPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(7.0), // Slightly smaller than container
                              child: Image.file(
                                File(lastThumbnailPath!),
                                width: 50, // Fill container
                                height: 50, // Fill container
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                   // Handle potential image loading errors
                                   return Icon(
                                       Icons.broken_image_outlined,
                                       color: Colors.grey[700],
                                       size: 30,
                                   );
                                },
                              ),
                            )
                          : Icon(
                                Icons.video_library_outlined, // Outline version
                                color: lastVideoPath != null // Color based on whether *any* video exists
                                    ? Colors.black87 // Show a darker icon if a video path exists but thumbnail failed/not generated yet
                                    : Colors.white54, // Lighter if no video at all
                                size: 30,
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}