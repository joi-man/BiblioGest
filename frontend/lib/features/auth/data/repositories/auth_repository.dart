import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/usuario.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient.dio);
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {
        'correo_o_usuario': request.correoOUsuario,
        'contrasena': request.contrasena,
      },
    );
    return LoginResponse.fromJson(response.data);
  }

  Future<Usuario> getCurrentUser(String token) async {
    final response = await _dio.get(
      '/api/auth/yo',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Usuario.fromJson(response.data);
  }
}
