import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/reel/privacy_option.dart';
import 'package:mobile/models/reel/video_item.dart';
import 'package:mobile/ui/routes/router_enum.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

const String _profileImageUrl =
    'https://res.cloudinary.com/dpmykt0af/image/upload/v1744224571/ImageMagic/jwvonkoaqb7f1yjdbl0k.jpg';
const String _username = '@that_mind_trainer';
const int _followingCount = 3;
const String _followersCount = '197.0K';
const String _likesCount = '8.1M';
const String _bioText = '🚀 Road to 200k ';

const String _s3VideoUrl =
    'https://blockchainsocialmedia-reelandprofile.s3.amazonaws.com/POC/Download%20%281%29.mp4';

final List<VideoItem> _userVideosList = [
  VideoItem(
    id: 'user_video_1',
    videoUrl: _s3VideoUrl,
    username: "Daniel",
    description: "EVERY GYM RAT ON PUMP",
    profileImageUrl: _profileImageUrl,
    likeCount: 19300000,
    commentCount: 400,
    shareCount: 100,
    isBookmarked: true,
    isLiked: true,
    timestamp: DateTime.now(),
    isPremiumContent: true,
    duration: 18,
    mentionedUsers: null,
    privacy: PrivacyOption.public,
    allowComments: true,
    allowSaveToDevice: false,
    saveWithWatermark: true,
    audienceControlUnder18: false,
    walletId:""
  ),
  VideoItem(
    id: 'user_video_2',
    videoUrl:
        'https://res.cloudinary.com/dpmykt0af/video/upload/v1745257849/Download_nkza7a.mp4',
    username: "Daniel",
    description: "EAT HEAVY CARRY HEAVY",
    profileImageUrl: _profileImageUrl,
    likeCount: 13700000,
    commentCount: 500,
    shareCount: 120,
    isBookmarked: true,
    isLiked: false,
    timestamp: DateTime.now().subtract(Duration(hours: 1)),
    isPremiumContent: false,
    duration: 25,
    mentionedUsers: null,
    privacy: PrivacyOption.followers,
    allowComments: false,
    allowSaveToDevice: true,
    saveWithWatermark: false,
    audienceControlUnder18: true,
    walletId:""
  ),
  VideoItem(
    id: 'user_video_3',
    videoUrl:
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    username: "Alice",
    description: "Beautiful butterfly",
    profileImageUrl: 'https://example.com/alice_profile.jpg',
    likeCount: 1500,
    commentCount: 50,
    shareCount: 10,
    isBookmarked: false,
    isLiked: true,
    timestamp: DateTime.now().subtract(Duration(days: 2)),
    isPremiumContent: false,
    duration: 35,
    privacy: PrivacyOption.onlyYou,
    allowComments: true,
    allowSaveToDevice: true,
    saveWithWatermark: true,
    audienceControlUnder18: false,
    walletId:""
  ),
];

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Mind Trainer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // TODO: Implement notification action
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement share action
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(_profileImageUrl),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              _username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Following', _followingCount.toString()),
              _buildStatColumn('Followers', _followersCount),
              _buildStatColumn('Likes', _likesCount),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Follow action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            _bioText,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.grid_view_rounded, color: Colors.white),
              Icon(Icons.favorite_border, color: Colors.grey),
              Icon(Icons.bookmark_border, color: Colors.grey),
              Icon(Icons.lock_outline, color: Colors.grey),
            ],
          ),
          const Divider(color: Colors.grey, height: 20, thickness: 0.5),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 9 / 16,
            ),
            itemCount: _userVideosList.length,
            itemBuilder: (context, index) {
              final video = _userVideosList[index];
              return _buildVideoGridItem(context, index, video);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildVideoGridItem(BuildContext context, int index, VideoItem video) {
    return GestureDetector(
      onTap: () {
        context.push(
          RouterEnum.profileVideoPlayerView.routeName,
          extra: {
            'userVideos': _userVideosList,
            'initialIndex': index,
          },
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
                          "Error displaying generated thumbnail: $error");
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

            // View Count
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
                              : Icons
                                  .visibility_off, 
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
