import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storageService;

  AuthInterceptor({required this.storageService});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

Dio createDioClient({required StorageService storageService}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
      sendTimeout: const Duration(seconds: ApiConstants.sendTimeoutSeconds),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor(storageService: storageService));
  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: true,
    ),
  );

  return dio;
}
