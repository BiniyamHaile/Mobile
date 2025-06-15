// lib/string_extension.dart

import 'package:flutter/widgets.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:provider/provider.dart';

extension StringLocalization on String {
  /// Translates the string key using the LanguageService.
  /// We use `context.read` here because we just need to call the `translate`
  /// method and don't need to rebuild this extension when the language changes.
  /// The widget that uses this string will be responsible for rebuilding.
  String tr(BuildContext context) {
    return context.read<LanguageService>().translate(this);
  }
}