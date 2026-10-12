import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/archivos/formato_exportacion.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
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

  /// Una página de usuarios con búsqueda y filtros. El token lo agrega el cliente HTTP.
  Future<PaginaResultado<Usuario>> buscar({
    String texto = '',
    String? rol,
    bool? activo,
    int pagina = 1,
    int tamano = 10,
  }) async {
    final respuesta = await _dio.get(
      '/api/usuarios/buscar',
      queryParameters: {
        ..._filtros(texto, rol, activo),
        'pagina': pagina,
        'tamano': tamano,
      },
    );
    return PaginaResultado.desdeJson(respuesta.data, Usuario.fromJson);
  }

  /// Descarga todos los usuarios que cumplen el filtro (no solo una página).
  Future<Uint8List> exportar(
    FormatoExportacion formato, {
    String texto = '',
    String? rol,
    bool? activo,
  }) async {
    final respuesta = await _dio.get<List<int>>(
      '/api/usuarios/exportar',
      queryParameters: {
        ..._filtros(texto, rol, activo),
        'formato': formato.extension,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(respuesta.data!);
  }

  /// Parámetros de filtro comunes a la búsqueda y a la exportación.
  Map<String, dynamic> _filtros(String texto, String? rol, bool? activo) => {
    if (texto.trim().isNotEmpty) 'q': texto.trim(),
    if (rol != null) 'rol': rol,
    if (activo != null) 'activo': activo,
  };

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

  Future<Usuario> actualizar(
    String id,
    Map<String, dynamic> datos,
    String token,
  ) async {
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
