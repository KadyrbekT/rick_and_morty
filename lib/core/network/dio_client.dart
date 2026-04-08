import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugLog(o.toString()),
      ),
    );

    return dio;
  }

  static void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print('[DioClient] $message');
      return true;
    }());
  }
}
