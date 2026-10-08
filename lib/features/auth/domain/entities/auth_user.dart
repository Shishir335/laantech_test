class AuthUser {
  final int id;
  final String username;
  final String? createdAt;

  const AuthUser({
    required this.id,
    required this.username,
    this.createdAt,
  });
}

class AuthSession {
  final AuthUser user;
  final String token;
  final String tokenType;
  final int expiresIn;

  const AuthSession({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.expiresIn,
  });
}
