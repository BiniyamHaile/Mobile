import "package:flutter/material.dart";

class ScreenSizeUtils {
  final BuildContext context;
  final Size _screenSize;
  final double keyboardHeight;

  ScreenSizeUtils(this.context)
      : _screenSize = MediaQuery.of(context).size,
        keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

  Size get screenSize => _screenSize;

  double scaledScreenWidth(double scale) => _screenSize.width * scale;

  double scaledScreenHeight(double scale) => _screenSize.height * scale;

  double scaledShortestScreenSide(double scale) =>
      _screenSize.shortestSide * scale;

  double scaledLongestScreenSide(double scale) =>
      _screenSize.longestSide * scale;

  bool get isLandScape => _screenSize.width > _screenSize.height;

  double get smallPadding => _screenSize.width * 0.02;

  double get mediumPadding => _screenSize.width * 0.04;

  double get largePadding => _screenSize.width * 0.08;

  double scaledPadding(double scale) => _screenSize.width * scale;

  double horizontalSpacing([double scale = 1]) =>
      _screenSize.width * 0.01 * scale;

  double verticalSpacing([double scale = 1]) =>
      _screenSize.height * 0.01 * scale;
}
