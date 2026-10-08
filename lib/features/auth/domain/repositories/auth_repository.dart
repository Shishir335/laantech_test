import '../../../../core/network/api_result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthSession>> login({
    required String username,
    required String password,
  });

  Future<ApiResult<AuthSession>> register({
    required String username,
    required String password,
  });

  Future<void> logout();

  String? getSavedToken();

  String? getSavedUsername();
}
