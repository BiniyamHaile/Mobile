import 'package:mobile/models/reel/video_item.dart';

abstract class VideoFeedRepository {
  Future<List<VideoItem>> fetchVideos();

  Future<List<VideoItem>> fetchMoreVideos({
    required DateTime lastVideoCreatedAt,
  });
}
