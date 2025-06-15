import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/profile/profile_bloc.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> createThumbnail(String videoPath) async {
  Uint8List? bytes;
  try {
    bytes = await VideoThumbnail.thumbnailData(
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
  return bytes;
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial) {
          context.read<ProfileBloc>().add(LoadProfile());
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ProfileLoaded) {
          final user = state.user;
          final videos = state.videos ?? [];
          final isFollowing = state.isFollowing ?? false;

          return Scaffold(
            backgroundColor: theme.colorScheme.onPrimary,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.onPrimary,
              title: Text(
                user.name,
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings, color: theme.colorScheme.onBackground),
                  onPressed: () {
                    context.go(RouteNames.profileSetting);
                  },
                ),
                IconButton(
                  onPressed: () {
                    context.push(RouteNames.notifications);
                  },
                  icon: Icon(LucideIcons.bell, color: theme.colorScheme.onBackground),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: CachedNetworkImageProvider(
                      user.profilePic ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: theme.colorScheme.onBackground,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(context, 'Posts', videos.length.toString()),
                    _buildStatColumn(context, 'Followers', state.followers.length.toString()),
                    _buildStatColumn(context, 'Following', state.following.length.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isFollowing) {
                            context.read<ProfileBloc>().add(UnfollowUser(user.id));
                          } else {
                            context.read<ProfileBloc>().add(FollowUser(user.id));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          isFollowing ? 'Unfolloweeee' : 'Follow',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Message',
                          style: TextStyle(
                            color: Color.fromRGBO(143, 148, 251, 1),
                            fontSize: 16,
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
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontSize: 14
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.grid_view_rounded, color: theme.colorScheme.onBackground),
                    Icon(Icons.favorite_border, color: theme.colorScheme.onBackground),
                    Icon(Icons.bookmark_border, color: theme.colorScheme.onBackground),
                    Icon(Icons.lock_outline, color: theme.colorScheme.onBackground),
                  ],
                ),
                Divider(color: theme.colorScheme.onBackground.withOpacity(0.2), height: 20, thickness: 0.5),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                    childAspectRatio: 9 / 16,
                  ),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildVideoGridItem(context, index, video, videos);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    final theme = AppTheme.getTheme(context);
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
            fontSize: 14
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
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                        "Error displaying generated thumbnail: $error",
                      );
                      return Container(color: Colors.red.shade900);
                    },
                  );
                }

                return Container(
                  color: Colors.grey.shade900,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade600,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'Pinned',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.black, size: 12),
                      SizedBox(width: 2),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
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
                  const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    video.likeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (video.privacy != null && video.privacy != PrivacyOption.public)
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
                  color: Colors.grey,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
