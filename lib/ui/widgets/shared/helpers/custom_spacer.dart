import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class CustomSpacer extends StatelessWidget {
  final double? height;
  final double? width;
  final double scale;
  const CustomSpacer({
    super.key,
    this.height,
    this.width,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeUtils(context);

    return SizedBox(
      height: (height ?? screen.scaledScreenHeight(0.02)) * scale,
      width: (width ?? 0) * scale,
    );
  }
}
