import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<LoginResponse?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  String? get token => state.value?.accessToken;

  Future<void> login(String correoOUsuario, String contrasena) async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(authRepositoryProvider);
      final loginResponse = await repository.login(
        LoginRequest(
          correoOUsuario: correoOUsuario,
          contrasena: contrasena,
        ),
      );
      state = AsyncValue.data(loginResponse);
      authStateNotifier.setAuthenticated(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
    authStateNotifier.setAuthenticated(false);
  }
}
