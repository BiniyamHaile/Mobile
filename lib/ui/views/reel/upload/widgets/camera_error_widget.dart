// lib/widgets/camera_error_widget.dart
import 'package:flutter/material.dart';

class CameraErrorWidget extends StatelessWidget {
  final AsyncSnapshot<dynamic> snapshot; // Use dynamic as the future can complete with void or error

  const CameraErrorWidget({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We check snapshot.hasError in the parent, but we still need the error info here
    // if the future completed with an error. The message logic is slightly redundant but safe.
     final String errorMessage = snapshot.hasError
        ? "Camera initialization failed.\nError: ${snapshot.error.toString()}"
        : "No cameras available."; // Assuming no cameras means no controller/not initialized


    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 80),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            // Add retry button or instructions if needed
          ],
        ),
      ),
    );
  }
}