class ApiEndpoints {
  static const String baseUrl = "http://192.168.223.192:3000";
  static const String _authUrl = '$baseUrl/auth';
  static const String _notificationUrl = '$baseUrl/notifications';

  String get socketServerUrl => "https://dev-api.aladia.io";
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
}
