import 'dart:async';

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  static final _streamController = StreamController<int?>.broadcast();
  static final stream = _streamController.stream;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _streamController.add(err.response?.statusCode);
    super.onError(err, handler);
  }
}
