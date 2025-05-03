
import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class PinTheme {
  final Color activeColor;
  final Color selectedColor;
  final Color inactiveColor;
  final Color disabledColor;
  final Color activeFillColor;
  final Color selectedFillColor;
  final Color inactiveFillColor;
  final Color errorBorderColor;
  final double activeBorderWidth;
  final double selectedBorderWidth;
  final double inactiveBorderWidth;
  final double disabledBorderWidth;
  final double errorBorderWidth;
  final double fieldHeight;
  final double fieldWidth;
  final double borderWidth;
  final EdgeInsetsGeometry fieldOuterPadding;
  final List<BoxShadow>? activeBoxShadows;
  final List<BoxShadow>? inactiveBoxShadows;

  const PinTheme({
    required this.activeColor,
    required this.selectedColor,
    required this.inactiveColor,
    required this.disabledColor,
    required this.activeFillColor,
    required this.selectedFillColor,
    required this.inactiveFillColor,
    required this.errorBorderColor,
    required this.activeBorderWidth,
    required this.selectedBorderWidth,
    required this.inactiveBorderWidth,
    required this.disabledBorderWidth,
    required this.errorBorderWidth,
    required this.fieldHeight,
    required this.fieldWidth,
    required this.borderWidth,
    required this.fieldOuterPadding,
    this.activeBoxShadows,
    this.inactiveBoxShadows,
  });

  factory PinTheme.fromAppTheme(BuildContext context) {
    final appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);

    return PinTheme(
      activeColor: appTheme.primaryColor,
      selectedColor: appTheme.primaryColor,
      inactiveColor: appTheme.primaryColor,
      disabledColor: appTheme.disabledColor,
      activeFillColor: appTheme.primaryColor,
      selectedFillColor: appTheme.primaryColor,
      inactiveFillColor: appTheme.primaryColor,
      errorBorderColor: appTheme.colorScheme.error,
      activeBorderWidth: screen.scaledShortestScreenSide(0.01),
      selectedBorderWidth: screen.scaledShortestScreenSide(0.01),
      inactiveBorderWidth: screen.scaledShortestScreenSide(0.01),
      disabledBorderWidth: screen.scaledShortestScreenSide(0.01),
      errorBorderWidth: screen.scaledShortestScreenSide(0.01),
      fieldHeight: screen.scaledShortestScreenSide(0.1),
      fieldWidth: screen.scaledShortestScreenSide(0.1),
      borderWidth: screen.scaledShortestScreenSide(0.01),
      fieldOuterPadding: EdgeInsets.all(screen.scaledShortestScreenSide(0.01)),
    );
  }
}
