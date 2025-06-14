import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  const PostButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.iconSize = 18.0,
    this.textSize = 14.0,
    // this.textColor = Colors.grey,
  });

  final Widget icon;
  final String text;
  final VoidCallback onTap;
  final double iconSize;
  final double textSize;
  // final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: FittedBox(
                fit: BoxFit.contain,
                child: icon,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: textSize,
                // color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
