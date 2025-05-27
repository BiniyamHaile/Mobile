// lib/widgets/camera_initializing_widget.dart
import 'package:flutter/material.dart';

class CameraInitializingWidget extends StatelessWidget {
  const CameraInitializingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}