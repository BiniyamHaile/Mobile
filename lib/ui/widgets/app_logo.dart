import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/theme/theme_helper.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final textTheme = theme.textTheme;

    return Text(
      'EthioMedia',
      style: textTheme.headlineMedium?.copyWith(
        fontFamily: 'EduNSWACTCursive',
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
        fontSize: 24
      ),
    );
  }
}