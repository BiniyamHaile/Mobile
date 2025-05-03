
import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class MainAppButton extends StatelessWidget {
  const MainAppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.gradient,
    this.width,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
  });

  final String text;
  final bool loading;
  final bool disabled;
  final double? width;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);
    final opacity = 0.5;

    return Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),

        color: backgroundColor ?? appTheme.highlightColor,
        ),
        height: screen.scaledLongestScreenSide(0.06),
        width: width ?? screen.scaledShortestScreenSide(0.8),
        child: TextButton(
          onPressed: disabled || loading ? null : onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              prefixIcon ?? SizedBox.shrink(),
              Center(
                child: loading
                    ? CircularProgressIndicator(
                        color: appTheme.primaryColor,
                      )
                    : Text(
                        text,
                        style: appTheme.textTheme.labelMedium?.copyWith(
                          color: appTheme.primaryColor,
                        ),
                      ),
              ),
              suffixIcon ?? SizedBox.shrink(),
            ],
          ),
        ),
    );
  }
}
