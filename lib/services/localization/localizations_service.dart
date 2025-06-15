import 'package:flutter/material.dart';
import 'package:mobile/services/localization/am_et.dart';
import 'package:mobile/services/localization/en_us.dart';
import 'package:mobile/services/localization/om_et.dart';

class LanguageService extends ChangeNotifier {
  // Default language is English
  String _currentLanguage = 'am';

  String get currentLanguage => _currentLanguage;

  // Your translation strings
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': enUS,
    'am': amET,
    'om': omET,
  };

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }
}