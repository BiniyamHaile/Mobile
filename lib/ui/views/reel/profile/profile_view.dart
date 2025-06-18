import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/profile/profile_bloc.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:provider/provider.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> createThumbnail(String videoPath) async {
  try {
    return await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 75,
      timeMs: 1000,
    );
  } catch (e) {
    debugPrint("Error generating thumbnail for $videoPath: $e");
    return null;
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final theme = AppTheme.getTheme(context);

        // Get user data if available, otherwise use default values
        final user = state is ProfileLoaded ? state.user : null;
        final videos = state is ProfileLoaded ? (state.videos ?? []) : [];
        final followers = state is ProfileLoaded ? (state.followers ?? []) : [];
        final following = state is ProfileLoaded ? (state.following ?? []) : [];
        final isFollowing = state is ProfileLoaded ? (state.isFollowing ?? false) : false;

        // Load profile if in initial state
        if (state is ProfileInitial) {
          context.read<ProfileBloc>().add(LoadProfile());
        }

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.onPrimary,
            // centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              onPressed: () => context.go(RouteNames.feed),
            ),
            title: Text(
              user?.name ?? 'Profile',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            actions: [
              // language selector
              PopupMenuButton<Locale>(
                icon: Icon(Icons.language,
                    color: theme.colorScheme.primary),
                onSelected: languageService.changeLocale,
                itemBuilder: (_) => languageService.supportedLocales
                    .map((loc) => PopupMenuItem(
                          value: loc,
                          child: Text(loc.languageCode.toUpperCase()),
                        ))
                    .toList(),
              ),
              IconButton(
                icon: Icon(Icons.settings,
                    color: theme.colorScheme.primary),
                onPressed: () =>
                    context.go(RouteNames.profileSetting),
              ),
              IconButton(
                icon: Icon(LucideIcons.bell,
                    color: theme.colorScheme.primary,
                ),
                onPressed: () =>
                    context.push(RouteNames.notifications),
              ),
            ],
          ),
          body: _buildBody(context, state, theme, languageService, user, videos.cast<VideoItem>(), followers, following, isFollowing),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState state,
    ThemeData theme,
    LanguageService languageService,
    dynamic user,
    List<VideoItem> videos,
    List<dynamic> followers,
    List<dynamic> following,
    bool isFollowing,
  ) {
    // Show loading indicator for body content while loading
    if (state is ProfileInitial || state is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProfileError) {
      return Center(
        child: Text(
          '${state.message}',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    if (state is ProfileLoaded && user != null) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 20),
          // also show current language at top-right of content
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButton<Locale>(
              value: languageService.currentLocale,
              underline: const SizedBox(),
              onChanged: (loc) {
                if (loc != null) languageService.changeLocale(loc);
              },
              items: languageService.supportedLocales
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child:
                            Text(loc.languageCode.toUpperCase()),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(
                user.profilePic ??
                    'https://via.placeholder.com/150',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '@${user.username}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                context,
                AppStrings.posts.tr(context),
                videos.length.toString(),
              ),
              _buildStatColumn(
                context,
                AppStrings.followers.tr(context),
                followers.length.toString(),
              ),
              _buildStatColumn(
                context,
                AppStrings.following.tr(context),
                following.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // context.read<ProfileBloc>().add(
                    //       isFollowing
                    //           ? UnfollowUser(user.id)
                    //           : FollowUser(user.id),
                    //     );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    isFollowing
                        ? 
                        "unfollow"
                        : AppStrings.follow.tr(context),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                          color:
                              theme.colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement Message action
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: theme.colorScheme.primary),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    AppStrings.message.tr(context),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user.bio ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.grid_view_rounded,
                  color: theme.colorScheme.onBackground),
              Icon(Icons.favorite_border,
                  color: theme.colorScheme.onBackground),
              Icon(Icons.bookmark_border,
                  color: theme.colorScheme.onBackground),
              Icon(Icons.lock_outline,
                  color: theme.colorScheme.onBackground),
            ],
          ),
          Divider(
            color:
                theme.colorScheme.onBackground.withOpacity(0.2),
            height: 20,
            thickness: 0.5,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 9 / 16,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return _buildVideoGridItem(
                context,
                index,
                videos[index],
                videos,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildStatColumn(
      BuildContext context, String label, String count) {
    final theme = AppTheme.getTheme(context);
    return Column(
      children: [
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGridItem(
    BuildContext context,
    int index,
    VideoItem video,
    List<VideoItem> videos,
  ) {
    final theme = AppTheme.getTheme(context);

    return GestureDetector(
      onTap: () {
        context.push(
          RouterEnum.profileVideoPlayerView.routeName,
          extra: {'userVideos': videos, 'initialIndex': index},
        );
      },
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: createThumbnail(video.videoUrl),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: theme.colorScheme.onBackground,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (snap.hasData && snap.data != null) {
                  return Image.memory(
                    snap.data!,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  color: theme.colorScheme.onBackground,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 30,
                    ),
                  ),
                );
              },
            ),
            Container(color: Colors.black26),
            if (video.isBookmarked)
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                   "Pinned",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (video.isPremiumContent == true)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          size: 12, color: theme.colorScheme.onSecondary),
                      const SizedBox(width: 2),
                      Text(
                        "Premium",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Row(
                children: [
                  Icon(Icons.play_arrow,
                      size: 16, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 4),
                  Text(
                    video.likeCount.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (video.description.isNotEmpty)
              Positioned(
                bottom: 25,
                left: 5,
                right: 5,
                child: Text(
                  video.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (video.privacy != null &&
                video.privacy != PrivacyOption.public)
              Positioned(
                bottom: 5,
                right: 5,
                child: Icon(
                  video.privacy == PrivacyOption.followers
                      ? Icons.group
                      : video.privacy == PrivacyOption.friends
                          ? Icons.people
                          : video.privacy == PrivacyOption.onlyYou
                              ? Icons.lock
                              : Icons.visibility_off,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
