import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/auth_state.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/features/auth/data/models/login_request.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<LoginResponse?>>((ref) {
  return AuthNotifier(ref);
});

/// Token de la sesión actual, o `null` si no hay sesión.
///
/// Los proveedores de datos lo observan para volver a cargar cuando cambia
/// la persona que usa la aplicación.
final tokenSesionProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).value?.accessToken;
});

class AuthNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null)) {
    _ref.read(dioClientProvider).alSesionExpirada = _alSesionExpirada;
  }

  /// El servidor ya no acepta la sesión: se cierra y se avisa en el login.
  void _alSesionExpirada() {
    if (state.value == null) return;
    authStateNotifier.avisoAlLogin = 'Tu sesión terminó. Inicia sesión de nuevo.';
    logout();
  }

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
      // Desde aquí todas las peticiones llevan el token sin que cada
      // repositorio tenga que pasarlo.
      _ref.read(dioClientProvider).setToken(loginResponse.accessToken);
      state = AsyncValue.data(loginResponse);
      authStateNotifier.iniciarSesion(loginResponse.usuario.rol);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void logout() {
    _ref.read(dioClientProvider).clearToken();
    state = const AsyncValue.data(null);
    authStateNotifier.cerrarSesion();
  }
}
