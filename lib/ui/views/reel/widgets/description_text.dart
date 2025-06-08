import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/ui/styles/app_colors.dart';

class DescriptionText extends StatefulWidget {
  const DescriptionText({super.key, required this.text});

  final String text;

  @override
  _DescriptionTextState createState() => _DescriptionTextState();
}

class _DescriptionTextState extends State<DescriptionText> {
  bool _isExpanded = false;
  late TapGestureRecognizer _tapGestureRecognizer;

  final appColors = AppColors();

  static const int _maxLength = 80;
  static const String _seeMoreText = '... See More';
  static const String _seeLessText = ' See Less';

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _handleTap;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textSpan = <TextSpan>[];
    String displayDescription = widget.text;
    String? linkText;

    if (widget.text.length > _maxLength) {
      if (_isExpanded) {
        displayDescription = widget.text;
        linkText = _seeLessText;
      } else {
        displayDescription = widget.text.substring(0, _maxLength);
        linkText = _seeMoreText;
      }
    }

    textSpan.add(
      TextSpan(
        text: displayDescription,
        style: TextStyle(color: appColors.whiteColor, fontSize: 18),
      ),
    );

    if (linkText != null) {
      textSpan.add(
        TextSpan(
          text: linkText,
          style: TextStyle(
            color: appColors.greyColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          recognizer: _tapGestureRecognizer,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: textSpan,
      ),
    );
  }
}
