import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/theme_helper.dart';
class UiHelpers {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    SnackBarType? type,
  }) {
    final ThemeData appTheme = Theme.of(context);
    Color? bgColor;
    switch (type) {
      case SnackBarType.success:
        bgColor = appTheme.colorScheme.success;
        break;
      case SnackBarType.error:
        bgColor = appTheme.colorScheme.error;
        break;
      default:
        bgColor = null;
    }
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String error) {
    showSnackBar(context: context, message: error, type: SnackBarType.error);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
        context: context, message: message, type: SnackBarType.success);
  }
}

enum SnackBarType { success, error }
