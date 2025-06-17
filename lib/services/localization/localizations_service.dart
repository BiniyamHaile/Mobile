import 'package:flutter/material.dart';
import 'package:mobile/services/localization/am_et.dart';
import 'package:mobile/services/localization/en_us.dart';
import 'package:mobile/services/localization/om_et.dart';

class LanguageService extends ChangeNotifier {
  // Default language is English
  String _currentLanguage = 'en';
  Locale _currentLocale = const Locale('en');

  String get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLocale;

  // Supported locales
  final List<Locale> supportedLocales = const [
    Locale('am'), // Amharic
    Locale('om'), // Afaan Oromo
    Locale('en'), // English
  ];

  // Your translation strings
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': enUS,
    'am': amET,
    'om': omET,
  };

  void changeLanguage(String languageCode) {
    _currentLanguage = languageCode;
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  void changeLocale(Locale locale) {
    _currentLocale = locale;
    _currentLanguage = locale.languageCode;
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }
}