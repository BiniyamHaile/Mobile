import 'package:mobile/common/constants.dart';

class HeaderUtils {
  static Map<String, String> createAuthorizationHeaders(
      {String? accessToken, String? contentType}) {
    return {
      if (accessToken != null) Constants.authorization: 'Bearer $accessToken',
      Constants.contentType: contentType ?? Constants.applicationJson,
    };
  }
}
