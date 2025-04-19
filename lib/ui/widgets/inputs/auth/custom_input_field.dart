import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? Function(String?)? onChanged;
  final void Function(String)? onSubmit;
  final double? height;
  final double? width;
  final Color? fillColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final EdgeInsetsGeometry? contentPadding;
  final TextAlign? alignment;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? margin;
  final bool? disabled;
  final String? initialValue;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool? enableInteractiveSelection;
  final bool? showCursor;
  final double cursorWidth;
  final Color? cursorColor;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int maxLines;
  final int? minLines;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onTap,
    this.prefixIcon,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.onSubmit,
    this.height,
    this.width,
    this.fillColor,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.contentPadding,
    this.labelText,
    this.alignment,
    this.maxLength,
    this.inputFormatters,
    this.margin,
    this.disabled,
    this.initialValue,
    this.autofillHints,
    this.autocorrect = true,
    this.enableInteractiveSelection,
    this.showCursor,
    this.cursorWidth = 2.0,
    this.cursorColor,
    this.decoration,
    this.style,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);
    return Container(
      margin: margin,
      alignment: Alignment.center,
      height: height,
      width: width ?? screen.scaledScreenWidth(1),
      child: TextFormField(
        initialValue: initialValue,
        validator: validator,
        controller: controller,
        obscureText: maxLines == 1 ? obscureText : false,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        autocorrect: autocorrect,
        enableInteractiveSelection: enableInteractiveSelection,
        showCursor: showCursor,
        cursorWidth: cursorWidth,
        cursorColor: cursorColor,
        focusNode: focusNode,
        onTap: onTap,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        textAlign: alignment ?? TextAlign.start,
        textInputAction:
            maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
        onChanged: onChanged,
        onFieldSubmitted: onSubmit,
        readOnly: disabled ?? false,
        decoration: decoration ??
            InputDecoration(
              border: border,
              enabledBorder: enabledBorder,
              disabledBorder: disabledBorder,
              focusedBorder: focusedBorder,
              errorBorder: errorBorder,
              focusedErrorBorder: focusedErrorBorder,
              hintText: hintText,
              labelText: labelText,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              contentPadding: contentPadding,
              counterText: '',
              counter: null,
              filled: true,
              fillColor: fillColor ??
                  (disabled ?? false
                      ? appTheme.colorScheme.surface
                      : appTheme.inputDecorationTheme.fillColor),
            ).applyDefaults(appTheme.inputDecorationTheme),
        style: style ??
            TextStyle(
              color: appTheme.colorScheme.primary,
            ),
        minLines: minLines,
        maxLines: maxLines,
      ),
    );
  }
}
