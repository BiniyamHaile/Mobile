import 'package:flutter/material.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';

class CustomCheckbox extends StatefulWidget {
  final bool value;
  final double gap;
  final void Function(bool?)? onChanged;
  final Widget? title;
  final EdgeInsetsGeometry padding;
  final Color? color;
  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.title,
    this.gap = 8.0,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late ValueNotifier<bool> valueListenable;

  @override
  void initState() {
    valueListenable = ValueNotifier(widget.value);
    super.initState();
  }

  @override
  void dispose() {
    valueListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);
    final title = widget.title;

    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: widget.color ?? appTheme.primaryColor),
                borderRadius: BorderRadius.circular(
                    screen.scaledShortestScreenSide(0.005))),
            height: screen.scaledShortestScreenSide(0.05),
            width: screen.scaledShortestScreenSide(0.05),
            child: ValueListenableBuilder(
              valueListenable: valueListenable,
              builder: (context, value, child) {
                return Checkbox(
                  value: value,
                  onChanged: (value) {
                    final onChanged = widget.onChanged;
                    if (onChanged != null) {
                      onChanged(value);
                    }
                    valueListenable.value = value ?? false;
                  },
                  checkColor: appTheme.primaryColor,
                  side: BorderSide.none,
                );
              },
            ),
          ),
          SizedBox(width: widget.gap),
          title ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
