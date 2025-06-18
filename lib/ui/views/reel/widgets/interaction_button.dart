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
    // Changed default outlineColor here
    this.outlineColor = const Color.fromRGBO(143, 148, 251, 1),
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

    // Generate shadows to create the outline effect
    // We iterate around the center (0,0) to create the shadow in all directions
    // The step size determines the density of the shadow points
    final double step = outlineWidth / 2.0;
    final List<Shadow> shadows = [];

    // Basic outline points
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, 0), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, 0), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(0, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(0, -outlineWidth), blurRadius: 0));

    // Diagonal points
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(outlineWidth, -outlineWidth), blurRadius: 0));
    shadows.add(Shadow(color: outlineColor, offset: Offset(-outlineWidth, -outlineWidth), blurRadius: 0));

     // Add intermediate points for a thicker/smoother outline if needed
     // This loop adds points between the main directions
     for (double x = -outlineWidth; x <= outlineWidth; x += step) {
        for (double y = -outlineWidth; y <= outlineWidth; y += step) {
           // Avoid adding the center (0,0) or points already added
           if ((x.abs() != outlineWidth || y.abs() != outlineWidth) && (x != 0 || y != 0) && (x.abs() != outlineWidth && y.abs() != outlineWidth)) {
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


     // Use a Set to ensure unique shadows and remove duplicates
     final uniqueShadows = <Shadow>{};
     for (var s in shadows) {
       uniqueShadows.add(s);
     }

    return uniqueShadows.toList();
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap!();
        }
        // Check if shareLink is provided before attempting to share
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
            size: 28,
          ),
          // Only show count if it's not -1
          if (count != -1)
            Text(
              count.toString(),
              style: TextStyle(
                color: appColors.whiteColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}