import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/styles/app_colors.dart';
import 'package:mobile/ui/views/reel/widgets/follow_button.dart';

class UserHeader extends StatelessWidget {
  UserHeader({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.profileId,
  });

  final String profileImageUrl;
  final String username;
  final String profileId;

  final appColors = AppColors();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).push(
          RouterEnum.profileView.routeName.replaceAll(':profileId', profileId),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(profileImageUrl),
          ),
          const SizedBox(width: 8),
          Text(
            username,
            style: TextStyle(
              color: appColors.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 8),
          FollowButton(),
        ],
      ),
    );
  }
}
