import 'package:flutter/material.dart';
import 'package:mobile/ui/styles/app_colors.dart';


class FollowButton extends StatelessWidget {
   FollowButton({super.key});

   final appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(border: Border.all(color: appColors.whiteColor), borderRadius: BorderRadius.circular(8)),
      child: Text("Follow", style: TextStyle(color: appColors.whiteColor, fontSize: 16)),
    );
  }
}
