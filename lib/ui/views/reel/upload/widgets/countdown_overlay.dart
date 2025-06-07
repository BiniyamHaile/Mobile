// lib/widgets/countdown_overlay.dart
import 'package:flutter/material.dart';

class CountdownOverlay extends StatelessWidget {
  final int countdownValue;

  const CountdownOverlay({Key? key, required this.countdownValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill( // Positioned.fill with Center centers the child
      child: Center(
        child: Text(
          countdownValue.toString(),
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [ // Add subtle shadow for visibility against various backgrounds
              Shadow(
                blurRadius: 5.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}