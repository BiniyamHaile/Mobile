import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/widgets/inputs/auth/custom_input_field.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool showPassword;
  final bool showVisibilityIcon;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChanged;

  const PasswordInput({
    super.key,
    required this.controller,
    this.hintText,
    this.showPassword = false,
    this.showVisibilityIcon = true,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  late ValueNotifier<bool> valueListenable;
  @override
  void initState() {
    _initValueNotifier();
    super.initState();
  }

  @override
  void dispose() {
    valueListenable.dispose();
    super.dispose();
  }

  void _initValueNotifier() {
    valueListenable = ValueNotifier(widget.showPassword);
  }

  @override
  Widget build(BuildContext context) {
    IconData showIcon = Icons.visibility;
    IconData hideIcon = Icons.visibility_off;
    final appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);
    final iconSize = screen.scaledShortestScreenSide(0.06);

    return ValueListenableBuilder(
      valueListenable: valueListenable,
      builder: (context, value, child) {
        return CustomTextField(
          controller: widget.controller,
          obscureText: !value,
          onChanged: widget.onChanged,
          hintText: widget.hintText ?? 'Password',
          keyboardType: TextInputType.visiblePassword,
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              valueListenable.value = !value;
            },
            icon: Icon(
              value ? hideIcon : showIcon,
              color: Colors.black,
            ),
          ),
          validator: widget.validator,
          cursorColor: Colors.deepPurple,
          style: TextStyle(color: Colors.black),
          fillColor: Colors.white,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Password',
            hintStyle: TextStyle(color: Colors.black),
            prefixIcon: Icon(Icons.lock, color: Colors.black),
            suffixIcon: IconButton(
              onPressed: () {
                valueListenable.value = !value;
              },
              icon: Icon(
                value ? hideIcon : showIcon,
                color: Colors.black,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        );
      },
    );
  }
}
