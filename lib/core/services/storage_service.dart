import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences preferences;

  StorageService({required this.preferences});

  Future<void> saveToken(String token) async {
    await preferences.setString(AppConstants.tokenStorageKey, token);
  }

  String? getToken() {
    return preferences.getString(AppConstants.tokenStorageKey);
  }

  Future<void> clearToken() async {
    await preferences.remove(AppConstants.tokenStorageKey);
  }

  Future<void> saveUsername(String username) async {
    await preferences.setString(AppConstants.usernameStorageKey, username);
  }

  String? getUsername() {
    return preferences.getString(AppConstants.usernameStorageKey);
  }

  Future<void> clearAll() async {
    await preferences.clear();
  }
}
