import 'package:dio/dio.dart';
import 'package:mobile/services/utls/auth_interceptor.dart';
import '../../../core/network/api_endpoints.dart';

class BaseRepository {
  BaseRepository() {
    dio.interceptors.add(AuthInterceptor());
  }

  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl, sendTimeout: const Duration(seconds: 30)));

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    Options? options,  
  }) async {
    print('Fetching data from: $url');
      print('Dio instance created with base URL: ${ApiEndpoints.baseUrl}');

    var response = await dio.get(
      url,
      queryParameters: queryParameters,
      options: options ?? Options(headers: headers),
    );

    print('Response: ${response.data}');
    return response;
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? headers,
    required Map<String, dynamic> body,
  }) async {
    return await dio.post(
      url,
      data: body,
      options: Options(headers: headers),
    );
  }

  Future<Response> put(String url,
      {Map<String, dynamic>? headers, required body}) async {
    return await dio.put(
      url,
      data: body,
      options: Options(headers: headers),
    );
  }

  Future<Response> delete(String url,
      {Map<String, dynamic>? headers, Map<String, dynamic>? body}) async {
    return await dio.delete(
      url,
      data: body,
      options: Options(headers: headers),
    );
  }

  Future<Response> patch(String url,
      {Map<String, dynamic>? headers, Map<String, dynamic>? body}) async {
    return await dio.patch(
      url,
      data: body,
      options: Options(headers: headers),
    );
  }
}
