import 'package:dio/dio.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.apiService,
    required this.storageService,
  });

  @override
  Future<ApiResult<AuthSession>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiService.login(username, password);
      if (response.success && response.user != null && response.token != null) {
        final session = response.toEntity()!;
        await storageService.saveToken(session.token);
        await storageService.saveUsername(session.user.username);
        return ApiSuccess(session);
      } else {
        return ApiFailure(
          ServerException(message: response.error ?? 'Authentication failed'),
        );
      }
    } on DioException catch (dioErr) {
      final serverMsg = dioErr.response?.data is Map
          ? dioErr.response?.data['error']?.toString()
          : null;
      return ApiFailure(
        ServerException(
          message: serverMsg ?? dioErr.message ?? 'Network error occurred',
          statusCode: dioErr.response?.statusCode,
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<AuthSession>> register({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiService.register(username, password);
      if (response.success && response.user != null && response.token != null) {
        final session = response.toEntity()!;
        await storageService.saveToken(session.token);
        await storageService.saveUsername(session.user.username);
        return ApiSuccess(session);
      } else {
        return ApiFailure(
          ServerException(message: response.error ?? 'Registration failed'),
        );
      }
    } on DioException catch (dioErr) {
      final serverMsg = dioErr.response?.data is Map
          ? dioErr.response?.data['error']?.toString()
          : null;
      return ApiFailure(
        ServerException(
          message: serverMsg ?? dioErr.message ?? 'Registration network error',
          statusCode: dioErr.response?.statusCode,
        ),
      );
    } catch (e) {
      return ApiFailure(AppException(message: e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await storageService.clearToken();
  }

  @override
  String? getSavedToken() => storageService.getToken();

  @override
  String? getSavedUsername() => storageService.getUsername();
}
