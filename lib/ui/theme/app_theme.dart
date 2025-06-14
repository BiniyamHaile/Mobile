import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobile/ui/styles/style_constants.dart';
import 'package:mobile/ui/theme/app_colors.dart';
import 'package:mobile/ui/utils/font_scaling_utils.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class AppTheme {
  static AppColors appColors = AppColors();
  static Color accentSecondaryColor = appColors.accent2;
  static Color greenColor = appColors.greenColor;
  static Color brownYellowTransparent = appColors.brownYellowTransparent;
  static Color goldenYellowColor = appColors.goldenYellowColor;
  static Color lightGreenColor = appColors.lightGreenColor;
  static Color darkGreenColor = appColors.darkGreenColor;
  static Color darkRedColor = appColors.darkRedColor;
  static Color brightRedColor = appColors.brightRedColor;

  static ThemeData darkTheme(BuildContext context) {
    final screen = ScreenSizeUtils(context);

    return ThemeData(
      scaffoldBackgroundColor: appColors.darkGreyColor2,
      primaryColor: appColors.whiteColor,
      secondaryHeaderColor: appColors.accent1,
      dividerColor: appColors.greyColor.withOpacity(
        0.5,
      ), // Adjusted for better contrast
      shadowColor: appColors.darkGreyColor2,
      disabledColor: appColors.greyColor.withOpacity(0.7),
      highlightColor: appColors.accent1.withOpacity(0.2),
      focusColor: appColors.accent1,
      indicatorColor: appColors.accent1,
      hoverColor: appColors.accent1.withOpacity(0.3),
      canvasColor: appColors.darkGreyColor5,
      cardColor: appColors.greyColor6,
      splashColor: appColors.greyColor7.withOpacity(0.3),
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.darkGreyColor, // Harmonized with dark theme
        foregroundColor: appColors.whiteColor, // High contrast
      ),
      dividerTheme: DividerThemeData(
        color: appColors.greyColor.withOpacity(0.5),
      ),
      iconTheme: IconThemeData(color: appColors.whiteColor), // High contrast
      hintColor: appColors.greyColor.withOpacity(0.7), // Softer but readable
      colorScheme: ColorScheme.dark(
        primary: appColors.whiteColor,
        onPrimary: appColors.blackColor,
        surface: appColors.darkGreyColor2,
        onSurface: appColors.whiteColor,
        error: appColors.redColor,
        onError: appColors.whiteColor,
        onSecondary: appColors.whiteColor,
      ),
      textTheme: _buildTextTheme(context, isDark: true),
      inputDecorationTheme: _buildDarkInputDecorationTheme(context, appColors),
      outlinedButtonTheme: _buildDarkOutlinedButtonThemeData(
        context,
        appColors,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            appColors.accent1,
          ), // Theme-consistent
          foregroundColor: WidgetStateProperty.all(
            appColors.whiteColor,
          ), // High contrast
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: screen.scaledScreenWidth(0.1),
              vertical: screen.scaledScreenHeight(0.02),
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    final screen = ScreenSizeUtils(context);

    return ThemeData(
      scaffoldBackgroundColor: appColors.whiteColor,
      primaryColor: appColors.darkGreenColor,
      secondaryHeaderColor: appColors.accent1,
      dividerColor: appColors.greyColor.withOpacity(0.5),
      shadowColor: appColors.greyColor.withOpacity(0.3),
      disabledColor: appColors.greyColor.withOpacity(0.5),
      highlightColor: appColors.accent1.withOpacity(0.2),
      focusColor: appColors.darkGreenColor,
      indicatorColor: appColors.darkGreenColor,
      hoverColor: appColors.greyColor.withOpacity(0.2),
      canvasColor: appColors.whiteColor,
      cardColor: appColors.accent2,
      splashColor: appColors.greyColor.withOpacity(0.3),
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.darkGreenColor,
        foregroundColor: appColors.whiteColor, // High contrast
      ),
      iconTheme: IconThemeData(color: appColors.blackColor), // High contrast
      hintColor: appColors.greyColor, // Readable on light background
      colorScheme: ColorScheme.light(
        primary: appColors.darkGreenColor,
        onPrimary: appColors.whiteColor,
        surface: appColors.whiteColor,
        onSurface: appColors.blackColor,
        error: appColors.redColor,
        onError: appColors.whiteColor,
        secondary: appColors.yellowColor2.withOpacity(0.3),
        onSecondary: appColors.blackColor,
      ),
      textTheme: _buildTextTheme(context, isDark: false),
      inputDecorationTheme: _buildLightInputDecorationTheme(context, appColors),
      outlinedButtonTheme: _buildLightOutlinedButtonThemeData(
        context,
        appColors,
      ),
    );
  }

  static TextTheme _buildTextTheme(
    BuildContext context, {
    required bool isDark,
  }) {
    return TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.bodyMediumFontSize,
        ),
        color: isDark ? appColors.whiteColor : appColors.blackColor,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.bodySmallFontSize,
        ),
        color: isDark
            ? appColors.greyColor.withOpacity(0.7)
            : appColors.greyColor,
        decorationColor: isDark
            ? appColors.greyColor.withOpacity(0.7)
            : appColors.greyColor,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Poppins',
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.labelSmallFontSize,
        ),
        fontWeight: FontWeight.normal,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Poppins',
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.labelMediumFontSize,
        ),
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        letterSpacing: 0.5,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.labelLargeFontSize,
        ),
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        letterSpacing: 0.5,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
          context,
          StyleConstants.labelLargeFontSize,
        ),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static InputDecorationTheme _buildDarkInputDecorationTheme(
    BuildContext context,
    AppColors colors,
  ) {
    return InputDecorationTheme(
      iconColor: colors.whiteColor, // High contrast
      contentPadding: const EdgeInsets.symmetric(
        horizontal: StyleConstants.inputHorizontalPadding,
        vertical: StyleConstants.inputVerticalPadding,
      ),
      filled: true,
      fillColor: colors.darkGreyColor5, // Darker fill for dark theme
      hintStyle: TextStyle(color: colors.greyColor.withOpacity(0.7)),
      labelStyle: TextStyle(color: colors.whiteColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StyleConstants.inputBorderRadius),
        borderSide: BorderSide(color: colors.greyColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.enabledInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.focusedInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.accent1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.errorInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.redColor),
      ),
    );
  }

  static InputDecorationTheme _buildLightInputDecorationTheme(
    BuildContext context,
    AppColors colors,
  ) {
    return InputDecorationTheme(
      iconColor: colors.blackColor, // High contrast
      contentPadding: const EdgeInsets.symmetric(
        horizontal: StyleConstants.inputHorizontalPadding,
        vertical: StyleConstants.inputVerticalPadding,
      ),
      filled: true,
      fillColor: colors.whiteColor, // Light fill for light theme
      hintStyle: TextStyle(color: colors.greyColor),
      labelStyle: TextStyle(color: colors.blackColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StyleConstants.inputBorderRadius),
        borderSide: BorderSide(color: colors.greyColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.enabledInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.greyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.focusedInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.darkGreenColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          StyleConstants.errorInputBorderRadius,
        ),
        borderSide: BorderSide(color: colors.redColor),
      ),
    );
  }

  static OutlinedButtonThemeData _buildDarkOutlinedButtonThemeData(
    BuildContext context,
    AppColors colors,
  ) {
    final screenUtils = ScreenSizeUtils(context);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: screenUtils.scaledScreenWidth(0.04),
          vertical: screenUtils.scaledScreenWidth(0.02),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colors.greyColor, width: 1),
        foregroundColor: colors.whiteColor, // High contrast
        textStyle: _buildTextTheme(context, isDark: true).bodySmall,
      ),
    );
  }

  static OutlinedButtonThemeData _buildLightOutlinedButtonThemeData(
    BuildContext context,
    AppColors colors,
  ) {
    final screenUtils = ScreenSizeUtils(context);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: screenUtils.scaledScreenWidth(0.04),
          vertical: screenUtils.scaledScreenWidth(0.02),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colors.greyColor, width: 1),
        foregroundColor: colors.blackColor, // High contrast
        textStyle: _buildTextTheme(context, isDark: false).bodySmall,
      ),
    );
  }

  static ThemeData getTheme(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark
        ? darkTheme(context)
        : lightTheme(context);
  }
}
