import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/usuario.dart';

final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UsuarioRepository(dioClient.dio);
});

class UsuarioRepository {
  final Dio _dio;

  UsuarioRepository(this._dio);

  Future<List<Usuario>> listar(String token) async {
    final response = await _dio.get(
      '/api/usuarios/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => Usuario.fromJson(json))
        .toList();
  }

  Future<Usuario> obtenerPorId(String id, String token) async {
    final response = await _dio.get(
      '/api/usuarios/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Usuario.fromJson(response.data);
  }

  Future<Usuario> crear(Map<String, dynamic> datos, String token) async {
    final response = await _dio.post(
      '/api/usuarios/',
      data: datos,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Usuario.fromJson(response.data);
  }

  Future<Usuario> actualizar(String id, Map<String, dynamic> datos,
      String token) async {
    final response = await _dio.put(
      '/api/usuarios/$id',
      data: datos,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Usuario.fromJson(response.data);
  }

  Future<void> eliminar(String id, String token) async {
    await _dio.delete(
      '/api/usuarios/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
