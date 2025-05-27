import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class ValidationIndicator extends StatelessWidget {
  final String? message;
  final Color? fillColor;
  final double fillPercentage;
  const ValidationIndicator({
    super.key,
    this.message,
    this.fillColor,
    this.fillPercentage = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final ScreenSizeUtils screen = ScreenSizeUtils(context);
    final ThemeData appTheme = Theme.of(context);
    final indicatorHeight = screen.scaledLongestScreenSide(0.0075);
    final indicatorVerticalMargin = screen.scaledLongestScreenSide(0.01);
    final indicatorWidth = screen.scaledShortestScreenSide(0.35);
    final indicatorRadius = indicatorHeight / 2;
    final copyMessage = message;

    return Padding(
      padding: EdgeInsets.only(bottom: screen.scaledLongestScreenSide(0.015)),
      child: Row(
        children: [
          Expanded(
            child: copyMessage == null
                ? const SizedBox.shrink()
                : Text(
                    copyMessage,
                    style: appTheme.textTheme.labelSmall
                        ?.copyWith(color: fillColor),
                  ),
          ),
          Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: indicatorVerticalMargin),
                width: indicatorWidth,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(indicatorRadius),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: indicatorVerticalMargin),
                width: indicatorWidth * (fillPercentage / 100),
                height: indicatorHeight,
                decoration: BoxDecoration(
                  color: fillColor ?? appTheme.primaryColor,
                  borderRadius: BorderRadius.circular(indicatorRadius),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
