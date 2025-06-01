class ApiEndpoints {
  static const String ip = "http://192.168.151.98";
  static const String baseUrl = "$ip:3000";
  static const String _authUrl = '$baseUrl/auth';
  static const String _notificationUrl = '$baseUrl/notifications';
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

  String get recentChats => "$_chatUrl/recent-chats";

  String retrieveMessages(String roomId) =>
      "$_chatUrl/messages/$roomId";
  String get sendMessage => "$_chatUrl/send";
}
