import '../../domain/entities/auth_user.dart';

class UserModel {
  final int id;
  final String username;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'created_at': createdAt,
      };

  AuthUser toEntity() => AuthUser(
        id: id,
        username: username,
        createdAt: createdAt,
      );
}

class AuthResponseModel {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? tokenType;
  final int? expiresIn;
  final String? error;

  AuthResponseModel({
    required this.success,
    this.user,
    this.token,
    this.tokenType,
    this.expiresIn,
    this.error,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
      error: json['error'] as String?,
    );
  }

  AuthSession? toEntity() {
    if (user != null && token != null) {
      return AuthSession(
        user: user!.toEntity(),
        token: token!,
        tokenType: tokenType ?? 'Bearer',
        expiresIn: expiresIn ?? 86400,
      );
    }
    return null;
  }
}
