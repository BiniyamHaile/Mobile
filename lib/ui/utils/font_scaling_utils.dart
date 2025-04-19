
import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class ResponsiveTextUtil {
  ResponsiveTextUtil(BuildContext context);

  static double adaptiveFontScaler(BuildContext context, double baseSize) {
    double screenWidth = ScreenSizeUtils(context).screenSize.shortestSide;

    double smallPhone = 320;
    double phone = 375;
    double largePhone = 414;
    double tablet = 768;
    double smallDesktop = 1024;

    double smallPhoneStart = 0.85;
    double phoneStart = 1.0;
    double largePhoneStart = 1.15;
    double tabletStart = 1.3;
    double smallDesktopStart = 1.5;

    double scalingFactor;

    double calculateFactor(double screenWidth, double start, double end,
        double startValue, double endValue) {
      double progress = (screenWidth - start) / (end - start);
      return startValue + progress * (endValue - startValue);
    }

    if (screenWidth <= smallPhone) {
      scalingFactor = smallPhoneStart;
    } else if (screenWidth <= phone) {
      scalingFactor = calculateFactor(
          screenWidth, smallPhone, phone, smallPhoneStart, phoneStart);
    } else if (screenWidth <= largePhone) {
      scalingFactor = calculateFactor(
          screenWidth, phone, largePhone, phoneStart, largePhoneStart);
    } else if (screenWidth <= tablet) {
      scalingFactor = calculateFactor(
          screenWidth, largePhone, tablet, largePhoneStart, tabletStart);
    } else if (screenWidth <= smallDesktop) {
      scalingFactor = calculateFactor(
          screenWidth, tablet, smallDesktop, tabletStart, smallDesktopStart);
    } else {
      scalingFactor = smallDesktopStart;
    }

    scalingFactor = scalingFactor.clamp(0.6, 1.5);

    return MediaQuery.of(context).textScaler.scale(baseSize * scalingFactor);
  }
}
