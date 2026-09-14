import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import '../models/material.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MaterialRepository(dioClient.dio);
});

class MaterialRepository {
  final Dio _dio;

  MaterialRepository(this._dio);

  Future<List<MaterialBiblioteca>> listar({String? token}) async {
    final response = await _dio.get(
      '/api/materiales/',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return (response.data as List)
        .map((json) => MaterialBiblioteca.fromJson(json))
        .toList();
  }

  Future<MaterialBiblioteca> obtenerPorId(String id, {String? token}) async {
    final response = await _dio.get(
      '/api/materiales/$id',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return MaterialBiblioteca.fromJson(response.data);
  }

  Future<MaterialBiblioteca> crear(MaterialBiblioteca material,
      {String? token}) async {
    final response = await _dio.post(
      '/api/materiales/',
      data: material.toJson(),
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return MaterialBiblioteca.fromJson(response.data);
  }

  Future<MaterialBiblioteca> crearMap(Map<String, dynamic> datos,
      {String? token}) async {
    final response = await _dio.post(
      '/api/materiales/',
      data: datos,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return MaterialBiblioteca.fromJson(response.data);
  }

  Future<MaterialBiblioteca> actualizar(String id, Map<String, dynamic> datos,
      {String? token}) async {
    final response = await _dio.put(
      '/api/materiales/$id',
      data: datos,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    return MaterialBiblioteca.fromJson(response.data);
  }

  Future<void> eliminar(String id, {String? token}) async {
    await _dio.delete(
      '/api/materiales/$id',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
  }
}
