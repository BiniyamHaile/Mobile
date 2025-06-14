class ApiEndpoints {
  static const String baseUrl = "http://192.168.252.192:3000";
  static const String _authUrl = '$baseUrl/auth';
  static const String _notificationUrl = '$baseUrl/notifications';
  static const String _reelUrl = '$baseUrl/reel';
  static const String _reelCommentUrl = '$baseUrl/reel-comment';
  static const String ip = "http://10.5.240.34";
  static const String _chatUrl = '$baseUrl/chat';

  String get socketServerUrl => "$ip:4000";
  String get notifications => _notificationUrl;
  String get userExistence => "$_authUrl/user-existence";
  String get loginWithEmail => "$_authUrl/login";
  String get loginWithGoogle => "$_authUrl/google";
  String get loginWithFacebook => "$_authUrl/facebook";
  String get loginWithApple => "$_authUrl/apple";
  String get appleCallback => "$_authUrl/apple/callback";
  String get sendRecoveryMail => "$_authUrl/forgot-password";
  String get resetPassword => "$_authUrl/reset-password";
  String get sendOtp => "$_authUrl/resend-verification";
  String get verifyOtp => "$_authUrl/verifyEmail";
  String get signup => "$_authUrl/register";
  String get logout => "$_authUrl/logout";
  String get updateWallet => "$_authUrl/updateprofile";

  // Reel Related
  String get reels => _reelUrl;
  String get likeReel => '$_reelUrl/like';
  String get shareReel => '$_reelUrl/share';
  String get reportReel => '$_reelUrl/report';
  String get reelComment => _reelCommentUrl;
  String get recentChats => "$_chatUrl/recent-chats";

  String retrieveMessages(String roomId) =>
      "$_chatUrl/messages/$roomId";
  String get sendMessage => "$_chatUrl/send";
}
