import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class InteractionButton extends StatelessWidget {
  final appColors = AppColors();

  InteractionButton({
    super.key,
    required this.id,
    required this.icon,
    required this.count,
    this.color = Colors.white,
    this.onTap,
    this.shareLink = '',
    this.outlineColor = Colors.black,
    this.outlineWidth = 1.5,
  });

  final String id;
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  final String shareLink;
  final Color outlineColor;
  final double outlineWidth;

  List<Shadow> _getOutlineShadows() {
    if (outlineWidth <= 0) {
      return [];
    }

    final double step = outlineWidth / 2.0;
    final List<Shadow> shadows = [];

    for (double x = -outlineWidth; x <= outlineWidth; x += step) {
      for (double y = -outlineWidth; y <= outlineWidth; y += step) {
        if (x != 0 || y != 0) {
           shadows.add(
             Shadow(
               color: outlineColor,
               offset: Offset(x, y),
               blurRadius: 0,
             ),
           );
        }
      }
    }
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, 0), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, 0), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(0, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(0, -outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, -outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, -outlineWidth), blurRadius: 0));

     final uniqueShadows = <Shadow>{};
     for (var s in shadows) {
       uniqueShadows.add(s);
     }

    return uniqueShadows.toList();
  }

  @override
  Widget build(BuildContext context) {
    final outlineShadows = _getOutlineShadows();

    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap!();
        }
        if (shareLink.isNotEmpty) {
          await Share.share(shareLink);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 36,
            shadows: outlineShadows,
          ),
          if (count != -1)
            Text(
              count.toString(),
              style: TextStyle(
                color: appColors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}