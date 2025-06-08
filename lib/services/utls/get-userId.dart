import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) return null;
  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  return decodedToken['userId']?.toString();
}
