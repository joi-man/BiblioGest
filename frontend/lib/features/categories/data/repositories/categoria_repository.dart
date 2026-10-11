import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/categoria.dart';

final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CategoriaRepository(dioClient.dio);
});

/// Acceso a la API de categorías. El token lo agrega el cliente HTTP.
class CategoriaRepository {
  CategoriaRepository(this._dio);

  final Dio _dio;

  Future<List<Categoria>> listar() async {
    final respuesta = await _dio.get('/api/categorias/');
    return (respuesta.data as List)
        .map((json) => Categoria.fromJson(json))
        .toList();
  }

  Future<Categoria> crear(Map<String, dynamic> datos) async {
    final respuesta = await _dio.post('/api/categorias/', data: datos);
    return Categoria.fromJson(respuesta.data);
  }

  Future<Categoria> actualizar(String id, Map<String, dynamic> datos) async {
    final respuesta = await _dio.put('/api/categorias/$id', data: datos);
    return Categoria.fromJson(respuesta.data);
  }

  Future<void> eliminar(String id) async {
    await _dio.delete('/api/categorias/$id');
  }
}
