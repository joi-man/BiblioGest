import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/categoria.dart';

final categoriaRepositoryProvider = Provider<CategoriaRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CategoriaRepository(dioClient.dio);
});

class CategoriaRepository {
  final Dio _dio;

  CategoriaRepository(this._dio);

  Future<List<Categoria>> listar(String token) async {
    final response = await _dio.get(
      '/api/categorias/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List)
        .map((json) => Categoria.fromJson(json))
        .toList();
  }

  Future<Categoria> obtenerPorId(String id, String token) async {
    final response = await _dio.get(
      '/api/categorias/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Categoria.fromJson(response.data);
  }

  Future<Categoria> crear(Map<String, dynamic> datos, String token) async {
    final response = await _dio.post(
      '/api/categorias/',
      data: datos,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Categoria.fromJson(response.data);
  }

  Future<Categoria> actualizar(String id, Map<String, dynamic> datos,
      String token) async {
    final response = await _dio.put(
      '/api/categorias/$id',
      data: datos,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Categoria.fromJson(response.data);
  }

  Future<void> eliminar(String id, String token) async {
    await _dio.delete(
      '/api/categorias/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
