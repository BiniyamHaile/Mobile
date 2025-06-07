import 'package:flutter/material.dart';
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
      dividerColor: appColors.darkGreyColor,
      shadowColor: appColors.darkGreyColor2,
      disabledColor: appColors.darkGreyColor3,
      highlightColor: appColors.darkGreyColor,
      focusColor: appColors.darkGreyColor3,
      indicatorColor: appColors.darkGreyColor,
      hoverColor: appColors.accent1,
      canvasColor: appColors.darkGreyColor5,
      cardColor: appColors.greyColor6,
      splashColor: appColors.greyColor7,
      appBarTheme: AppBarTheme(
        backgroundColor: appColors.whiteColor,
      ),
      dividerTheme: DividerThemeData(color: appColors.accent1),
      iconTheme: IconThemeData(
        color: appColors.greyColor,
      ),
      hintColor: appColors.greyColor,
      colorScheme: ColorScheme.dark(
          error: appColors.redColor, primary: appColors.blackColor),
      textTheme: _buildTextTheme(context, isDark: true),
      inputDecorationTheme: _buildDarkInputDecorationTheme(context, appColors),
      outlinedButtonTheme:
          _buildDarkOutlinedButtonThemeData(context, appColors),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(appColors.whiteColor),
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
            horizontal: screen.scaledScreenWidth(0.1),
            vertical: screen.scaledScreenHeight(0.02),
          )),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          )),
        ),
      ),
    );
  }

  static ThemeData lightTheme(BuildContext context) => ThemeData(
        scaffoldBackgroundColor: appColors.whiteColor,
        primaryColor: appColors.blackColor,
        secondaryHeaderColor: appColors.blackColor,
        dividerColor: appColors.accent3,
        shadowColor: appColors.accent4,
        disabledColor: appColors.accent4,
        highlightColor: appColors.accent4,
        focusColor: appColors.accent3,
        indicatorColor: appColors.accent4,
        hoverColor: appColors.greyColor,
        canvasColor: appColors.accent4,
        cardColor: appColors.accent2,
        splashColor: appColors.greyColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(
          color: appColors.greyColor,
        ),
        hintColor: appColors.greyColor,
        colorScheme: ColorScheme.light(
            primary:
                appColors.darkGreenColor,
            surface:
                appColors.whiteColor10,
            error: appColors.redColor,
            secondary: appColors.yellowColor2.withOpacity(0.1)),
        textTheme: _buildTextTheme(context, isDark: false),
        inputDecorationTheme:
            _buildLightInputDecorationTheme(context, appColors),
        outlinedButtonTheme:
            _buildLightOutlinedButtonThemeData(context, appColors),
      );

  static TextTheme _buildTextTheme(BuildContext context,
      {required bool isDark}) {
    return TextTheme(
      bodyMedium: TextStyle(
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.bodyMediumFontSize),
        color: isDark ? appColors.whiteColor : appColors.blackColor,
      ),
      bodySmall: TextStyle(
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.bodySmallFontSize),
        color: appColors.greyColor,
        decorationColor: appColors.greyColor,
      ),
      labelSmall: TextStyle(
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.labelSmallFontSize),
        fontWeight: FontWeight.normal,
      ),
      labelMedium: TextStyle(
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.labelMediumFontSize),
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        letterSpacing: 0.5,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.labelLargeFontSize),
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        color: isDark ? appColors.whiteColor : appColors.blackColor,
        letterSpacing: 0.5,
        fontSize: ResponsiveTextUtil.adaptiveFontScaler(
            context, StyleConstants.labelLargeFontSize),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static InputDecorationTheme _buildDarkInputDecorationTheme(
      BuildContext context, AppColors colors) {
    return InputDecorationTheme(
      iconColor: colors.blackColor,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: StyleConstants.inputHorizontalPadding,
          vertical: StyleConstants.inputVerticalPadding),
      filled: true,
      fillColor: colors.whiteColor,
      hintStyle: TextStyle(
        color: colors.greyColor50,
      ),
      labelStyle: TextStyle(
        color: colors.blackColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StyleConstants.inputBorderRadius),
        borderSide: BorderSide(
          color: colors.whiteColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.enabledInputBorderRadius),
        borderSide: BorderSide(
          color: colors.whiteColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.focusedInputBorderRadius),
        borderSide: BorderSide(
          color: colors.whiteColor,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.errorInputBorderRadius),
        borderSide: BorderSide(
          color: colors.redColor,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildLightInputDecorationTheme(
      BuildContext context, AppColors colors) {
    return InputDecorationTheme(
      iconColor: colors.whiteColor,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: StyleConstants.inputHorizontalPadding,
          vertical: StyleConstants.inputVerticalPadding),
      filled: true,
      fillColor: colors.accent1,
      hintStyle: TextStyle(
        color: colors.greyColor,
      ),
      labelStyle: TextStyle(
        color: colors.whiteColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StyleConstants.inputBorderRadius),
        borderSide: BorderSide(
          color: colors.blackColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.enabledInputBorderRadius),
        borderSide: BorderSide(
          color: colors.blackColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.focusedInputBorderRadius),
        borderSide: BorderSide(
          color: colors.blackColor,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(StyleConstants.errorInputBorderRadius),
        borderSide: BorderSide(
          color: colors.redColor,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildDarkOutlinedButtonThemeData(
      BuildContext context, AppColors colors) {
    final screenUtils = ScreenSizeUtils(context);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            horizontal: screenUtils.scaledScreenWidth(0.04),
            vertical: screenUtils.scaledScreenWidth(0.02)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: appColors.darkGreyColor2,
          width: 1,
        ),
        foregroundColor: appColors.whiteColor,
        textStyle: _buildTextTheme(context, isDark: true).bodySmall,
      ),
    );
  }

  static OutlinedButtonThemeData _buildLightOutlinedButtonThemeData(
      BuildContext context, AppColors colors) {
    final screenUtils = ScreenSizeUtils(context);

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            horizontal: screenUtils.scaledScreenWidth(0.04),
            vertical: screenUtils.scaledScreenWidth(0.02)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: appColors.accent4,
          width: 1,
        ),
        foregroundColor: appColors.blackColor,
        textStyle: _buildTextTheme(context, isDark: false).bodySmall,
      ),
    );
  }
}
