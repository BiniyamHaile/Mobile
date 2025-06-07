
import 'package:mobile/ui/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class Validator {
  final BuildContext context;
  Validator(this.context);

  final _minPasswordLength = 8;
  int get maxErrorStrength => 5;

  NewPasswordValidation validateNewPassword(String? password) {
    final colorScheme = Theme.of(context).colorScheme;
    final Map<int, Color> errorColors = {
      5: colorScheme.passwordError5,
      4: colorScheme.passwordError4,
      3: colorScheme.passwordError3,
      2: colorScheme.passwordError2,
      1: colorScheme.passwordError1,
      0: colorScheme.passwordError0,
    };
    int errorStrength = maxErrorStrength;
    String? errorMessage;

    if (password == null || password.trim().isEmpty) {
      return NewPasswordValidation('This field is required.',
          errorStrength, errorColors[errorStrength]);
    } else {
      errorStrength--;
      if (password.length >= _minPasswordLength) {
        errorStrength--;
      } else {
        errorMessage ??="too short password";
      }

      if (RegExp(r'[A-Z]').hasMatch(password)) {
        errorStrength--;
      } else {
        errorMessage ??="must contain uppercase letter";
      }

      if (RegExp(r'[0-9]').hasMatch(password)) {
        errorStrength--;
      } else {
        errorMessage ??="must contain number";
      }

      if (RegExp(r'[(@$!%*?&)]').hasMatch(password)) {
        errorStrength--;
      } else {
        errorMessage ??="must contain special character";
      }
      errorMessage ??="password is valid";

      return NewPasswordValidation(
          errorMessage, errorStrength, errorColors[errorStrength]);
    }
  }
}

class NewPasswordValidation {
  final String message;
  final int errorStrength;
  final Color? color;

  NewPasswordValidation(
    this.message,
    this.errorStrength,
    this.color,
  );
}
