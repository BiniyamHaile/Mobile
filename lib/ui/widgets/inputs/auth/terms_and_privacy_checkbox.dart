import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/widgets/inputs/shared/custom_checkbox.dart';

class TermsAndPrivacyCheckbox extends StatelessWidget {
  final bool checkboxValue;
  final void Function(bool?)? onChanged;
  final Color? color;
  const TermsAndPrivacyCheckbox({
    super.key,
    this.checkboxValue = false,
    this.onChanged,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSizeUtils(context);
    final appTheme = Theme.of(context);

    return CustomCheckbox(
      color: color,
      padding: EdgeInsets.only(left: screen.scaledShortestScreenSide(0.02)),
      value: checkboxValue,
      onChanged: onChanged,
      gap: screen.scaledShortestScreenSide(0.025),
      title: SizedBox(
        width: screen.scaledShortestScreenSide(0.695),
        child: Text.rich(
          TextSpan(
            text: 'I agree to the ',
            style: appTheme.textTheme.bodySmall?.copyWith(
              color: color?.withOpacity(0.8),
            ),
            children: [
              TextSpan(
                text: 'terms of service',
                style: appTheme.textTheme.labelSmall?.copyWith(
                  color: color,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                ),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'privacy policy',
                style: appTheme.textTheme.labelSmall?.copyWith(
                  color: color,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
