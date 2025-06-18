import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/theme/theme_helper.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final textTheme = theme.textTheme;

    return RichText(
      text: TextSpan(
        style: textTheme.headlineMedium?.copyWith(
          fontFamily: 'EduNSWACTCursive',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          height: 1.2,
        ),
        children: [
          // ሀ in green
          TextSpan(
            text: 'ሀ',
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w900,
              fontSize: 24,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.green[300]!.withOpacity(0.5),
                ),
              ],
            ),
          ),
          // በ in yellow
          TextSpan(
            text: 'በ',
            style: TextStyle(
              color: Colors.amber[600],
              fontWeight: FontWeight.w900,
              fontSize: 24,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.amber[300]!.withOpacity(0.5),
                ),
              ],
            ),
          ),
          // ሻ in red
          TextSpan(
            text: 'ሻ',
            style: TextStyle(
              color: Colors.red[600],
              fontWeight: FontWeight.w900,
              fontSize: 24,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.red[300]!.withOpacity(0.5),
                ),
              ],
            ),
          ),
          // Net in theme color
          TextSpan(
            text: 'Net',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
