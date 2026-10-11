import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/archivos/formato_exportacion.dart';
import 'package:frontend/core/modelos/pagina_resultado.dart';
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

  /// Una página del inventario con búsqueda y filtros (solo personal).
  Future<PaginaResultado<MaterialBiblioteca>> buscar({
    String texto = '',
    TipoMaterial? tipo,
    EstadoMaterial? estado,
    String? categoriaId,
    int pagina = 1,
    int tamano = 10,
  }) async {
    final respuesta = await _dio.get(
      '/api/materiales/buscar',
      queryParameters: {
        ..._filtros(texto, tipo, estado, categoriaId),
        'pagina': pagina,
        'tamano': tamano,
      },
    );
    return PaginaResultado.desdeJson(
        respuesta.data, MaterialBiblioteca.fromJson);
  }

  /// Descarga todo el inventario que cumple el filtro (no solo una página).
  Future<Uint8List> exportar(
    FormatoExportacion formato, {
    String texto = '',
    TipoMaterial? tipo,
    EstadoMaterial? estado,
    String? categoriaId,
  }) async {
    final respuesta = await _dio.get<List<int>>(
      '/api/materiales/exportar',
      queryParameters: {
        ..._filtros(texto, tipo, estado, categoriaId),
        'formato': formato.extension,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(respuesta.data!);
  }

  /// Parámetros de filtro comunes a la búsqueda y a la exportación.
  Map<String, dynamic> _filtros(String texto, TipoMaterial? tipo,
          EstadoMaterial? estado, String? categoriaId) =>
      {
        if (texto.trim().isNotEmpty) 'q': texto.trim(),
        if (tipo != null) 'tipo': tipo.valor,
        if (estado != null) 'estado': estado.valor,
        if (categoriaId != null) 'categoria_id': categoriaId,
      };

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
