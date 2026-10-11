import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/material.dart';
import '../models/material_etiquetas.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MaterialRepository(dioClient.dio);
});

/// Acceso a la API de materiales. El token lo agrega el cliente HTTP.
class MaterialRepository {
  MaterialRepository(this._dio);

  final Dio _dio;

  /// Lista materiales. Todos los filtros son opcionales.
  Future<List<MaterialBiblioteca>> listar({
    String? texto,
    TipoMaterial? tipo,
    EstadoMaterial? estado,
    bool soloDisponibles = false,
  }) async {
    final respuesta = await _dio.get(
      '/api/materiales/',
      queryParameters: {
        if (texto != null && texto.trim().isNotEmpty) 'q': texto.trim(),
        if (tipo != null) 'tipo': tipo.valor,
        if (estado != null) 'estado': estado.valor,
        if (soloDisponibles) 'disponible': true,
      },
    );
    return (respuesta.data as List)
        .map((json) => MaterialBiblioteca.fromJson(json))
        .toList();
  }

  Future<MaterialBiblioteca> crear(Map<String, dynamic> datos) async {
    final respuesta = await _dio.post('/api/materiales/', data: datos);
    return MaterialBiblioteca.fromJson(respuesta.data);
  }

  Future<MaterialBiblioteca> actualizar(
      String id, Map<String, dynamic> datos) async {
    final respuesta = await _dio.put('/api/materiales/$id', data: datos);
    return MaterialBiblioteca.fromJson(respuesta.data);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/materiales/$id');
  }
}
