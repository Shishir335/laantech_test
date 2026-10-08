import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? username;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.username,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? username,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(const AuthState()) {
    checkSavedSession();
  }

  void checkSavedSession() {
    final token = authRepository.getSavedToken();
    final username = authRepository.getSavedUsername();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        username: username ?? 'User',
      );
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await authRepository.login(
      username: username,
      password: password,
    );

    switch (result) {
      case ApiSuccess(data: final session):
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          username: session.user.username,
          token: session.token,
        );
        return true;
      case ApiFailure(exception: final err):
        state = state.copyWith(
          isLoading: false,
          errorMessage: err.message,
        );
        return false;
    }
  }

  Future<bool> register(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await authRepository.register(
      username: username,
      password: password,
    );

    switch (result) {
      case ApiSuccess(data: final session):
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          username: session.user.username,
          token: session.token,
        );
        return true;
      case ApiFailure(exception: final err):
        state = state.copyWith(
          isLoading: false,
          errorMessage: err.message,
        );
        return false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return serviceLocator<AuthRepository>();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(authRepository: ref.watch(authRepositoryProvider));
});
