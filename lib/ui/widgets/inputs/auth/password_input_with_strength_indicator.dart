import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/auth_form/auth_form_bloc.dart';
import 'package:mobile/core/validators/auth_validator.dart';
import 'package:mobile/ui/views/auth/password_input.dart';
import 'package:mobile/ui/views/auth/validation_indicator.dart';

class PasswordInputWithStrengthIndicator extends StatefulWidget {
  final TextEditingController controller;
  final bool showError;
  const PasswordInputWithStrengthIndicator({
    super.key,
    required this.controller,
    this.showError = false,
  });

  @override
  State<PasswordInputWithStrengthIndicator> createState() =>
      _PasswordInputWithStrengthIndicatorState();
}

class _PasswordInputWithStrengthIndicatorState
    extends State<PasswordInputWithStrengthIndicator> {
  double errorStrengthPercentage = 0.0;
  String? errorText;
  Color? indicatorColor;

  void _setError() {
    final validator = Validator(context);
    final maxStrength = validator.maxErrorStrength;
    final error = validator.validateNewPassword(widget.controller.text);
    errorText = error.message;
    errorStrengthPercentage =
        (maxStrength - (error.errorStrength)) * 100 / maxStrength;
    indicatorColor = error.color;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showError) {
      _setError();
    }

    return Wrap(
      children: [
        PasswordInput(
          controller: widget.controller,
          hintText: "Password",
          showPassword: false,
          onChanged: (value) {
            if (value == null) return;

            setState(() => _setError());
            context.read<AuthFormBloc>().add(PasswordChanged(value));
            return null;
          },
        ),
        ValidationIndicator(
          fillColor: indicatorColor,
          message: errorText,
          fillPercentage: errorStrengthPercentage,
        ),
      ],
    );
  }
}
