enum RouterEnum {
  dashboardView('/dashboard_view'),
  videoFeedView('/video_feed_view'),
  profileView('/profile_view/:profilid'),
  profileVideoPlayerView('/profile-video-player'),
  cameraScreen('/camera'),
  videoPreviewScreen('/video-preview/:videoPath'),
  postScreen('/post/:videoPath'),
  editPostScreen('/postedit');

  final String routeName;

  const RouterEnum(this.routeName);
}